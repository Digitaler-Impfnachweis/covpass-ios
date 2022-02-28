//
//  CertificateReissueRepository.swift
//  
//
//  Created by Thomas Kuleßa on 17.02.22.
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
    private let trustList: TrustList
    private let urlSession: CertificateReissueURLSessionProtocol

    public init(baseURL: URL, jsonDecoder: JSONDecoder, jsonEncoder: JSONEncoder, trustList: TrustList, urlSession: CertificateReissueURLSessionProtocol) {
        reissueURL = baseURL.appendingPathComponent(Constants.reissuePath)
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
        self.urlSession = urlSession
        self.trustList = trustList
    }

    public func reissue(_ webTokens: [ExtendedCBORWebToken]) -> Promise<CertificateReissueRepositoryResponse> {
        jsonEncoder
            .encodePromise(webTokens.map(\.vaccinationQRCodeData).certificateReissueRequestBody)
            .map(reissueRequest)
            .then(urlSession.httpRequest)
            .then(jsonDecoder.decodePromise)
            .then(certificateReissueRepositoryResponse)
    }

    private func reissueRequest(_ body: Data) -> URLRequest {
        var request = URLRequest(url: reissueURL)
        request.httpMethod = Constants.httpPostMethod
        request.httpBody = body
        return request
    }

    private func certificateReissueRepositoryResponse(_ response: [CertificateReissueResponse]) -> Promise<CertificateReissueRepositoryResponse> {
        let promises = response.map(cborWebToken)
        return when(fulfilled: promises)
    }

    private func cborWebToken(from response: CertificateReissueResponse) -> Promise<ExtendedCBORWebToken> {
        response.certificate
            .stripPrefix()
            .decodedBase45
            .then(\.decompressed)
            .then(CoseSign1Message.promise)
            .then(verifiedCBORWebToken)
            .map { cborWebToken in
                ExtendedCBORWebToken(
                    vaccinationCertificate: cborWebToken,
                    vaccinationQRCodeData: response.certificate
                )
            }
    }

    private func verifiedCBORWebToken(_ coseSign1Message: CoseSign1Message) -> Promise<CBORWebToken> {
        when(fulfilled: cborWebToken(from: coseSign1Message),
             HCert.verifyPromise(message: coseSign1Message, trustList: trustList)
        )
        .then(checkExtendedKeyUsage)
        .then(\.noFraud)
        .then(\.notExpired)
    }

    private func cborWebToken(from coseSign1Message: CoseSign1Message) -> Promise<CBORWebToken> {
        do {
            let json = try coseSign1Message.toJSON()
            return jsonDecoder.decodePromise(json)
        } catch {
            return .init(error: error)
        }
    }

    private func checkExtendedKeyUsage(cborWebToken: CBORWebToken, trustCertificate: TrustCertificate) -> Promise<CBORWebToken> {
        HCert.checkExtendedKeyUsagePromise(
            certificate: cborWebToken,
            trustCertificate: trustCertificate
        )
        .map { cborWebToken }
    }
}

private extension Array where Element == String {
    var certificateReissueRequestBody: CertificateReissueRequestBody {
        .init(action: .renew, certificates: self)
    }
}
