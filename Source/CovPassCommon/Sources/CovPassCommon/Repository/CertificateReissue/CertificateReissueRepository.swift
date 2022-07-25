//
//  CertificateReissueRepository.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

private enum Constants {
    static let reissuePath = "/api/certify/v2/reissue"
    static let httpPostMethod = "POST"
}

public class CertificateReissueRepository: CertificateReissueRepositoryProtocol {
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private let reissueURL: URL
    private let httpClient: HTTPClientProtocol
    private let coseSign1MessageConverter: CoseSign1MessageConverterProtocol

    public init(baseURL: URL, jsonDecoder: JSONDecoder, jsonEncoder: JSONEncoder, httpClient: HTTPClientProtocol, coseSign1MessageConverter: CoseSign1MessageConverterProtocol) {
        reissueURL = baseURL.appendingPathComponent(Constants.reissuePath)
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
        self.httpClient = httpClient
        self.coseSign1MessageConverter = coseSign1MessageConverter
    }

    public func renew(_ webTokens: [ExtendedCBORWebToken]) -> Promise<CertificateReissueRepositoryResponse> {
        reissue(webTokens.map(\.vaccinationQRCodeData).certificateRenewRequestBody)
    }
    
    public func extend(_ webTokens: [ExtendedCBORWebToken]) -> Promise<CertificateReissueRepositoryResponse> {
        reissue(webTokens.map(\.vaccinationQRCodeData).certificateExtendRequestBody)
    }
    
    private func reissue(_ certificateExtendRequestBody: CertificateReissueRequestBody) -> Promise<CertificateReissueRepositoryResponse> {
        Promise { seal in
            jsonEncoder
                .encodePromise(certificateExtendRequestBody)
                .map(reissueRequest)
                .then(httpClient.httpRequest)
                .then(mapResponse)
                .then(jsonDecoder.decodePromise)
                .then(certificateReissueRepositoryResponse)
                .done { seal.fulfill($0) }
                .catch { error in
                    seal.reject(
                        self.certificateReissueRepositoryError(from: error)
                    )
                }
        }
    }

    private func reissueRequest(_ body: Data) -> URLRequest {
        var request = URLRequest(url: reissueURL)
        request.httpMethod = Constants.httpPostMethod
        request.httpBody = body
        return request
    }

    private func mapResponse(_ response: HTTPClientResponse) -> Promise<Data> {
        guard let data = response.data else {
            return .init(error: CertificateReissueRepositoryFallbackError())
        }
        return .value(data)
    }

    private func certificateReissueRepositoryResponse(_ response: [CertificateReissueResponse]) -> Promise<CertificateReissueRepositoryResponse> {
        let promises = response.map(cborWebToken)
        return when(fulfilled: promises)
    }

    private func cborWebToken(from response: CertificateReissueResponse) -> Promise<ExtendedCBORWebToken> {
        coseSign1MessageConverter.convert(message: response.certificate)
    }

    private func certificateReissueRepositoryError(from error: Error) -> CertificateReissueRepositoryError {
        if let httpClientError = error as? HTTPClientError {
            switch httpClientError {
            case let .http(statusCode, data):
                guard let data = data,
                      let error = try? jsonDecoder.decode(CertificateReissueResponseError.self, from: data) else {
                    return statusCode.errorIfDataCouldNotBeDecoded()
                }
                return CertificateReissueRepositoryError(
                    error.error,
                    message: error.message
                )
            default:
                break
            }
        }
        return CertificateReissueRepositoryFallbackError()
    }
}

private extension Array where Element == String {
    var certificateRenewRequestBody: CertificateReissueRequestBody {
        .init(action: .renew, certificates: self)
    }
    
    var certificateExtendRequestBody: CertificateReissueRequestBody {
        .init(action: .extend, certificates: self)
    }
}

private extension Int {
    func errorIfDataCouldNotBeDecoded() -> CertificateReissueRepositoryError {
        switch self {
        case 429:
            return CertificateReissueRepositoryError("R429", message: nil)
        case 500:
            return CertificateReissueRepositoryError("R500", message: nil)
        default:
            return CertificateReissueRepositoryFallbackError()
        }
    }
}
