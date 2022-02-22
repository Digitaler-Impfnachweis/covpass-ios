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
    private let urlSession: CertificateReissueURLSessionProtocol

    public init(baseURL: URL, jsonDecoder: JSONDecoder, jsonEncoder: JSONEncoder, urlSession: CertificateReissueURLSessionProtocol) {
        reissueURL = baseURL.appendingPathComponent(Constants.reissuePath)
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
        self.urlSession = urlSession
    }

    public func reissue(_ certificates: [DigitalGreenCertificate]) -> Promise<CertificateReissueRepositoryResponse> {
        compressAndEncode(certificates)
            .map(\.certificateReissueRequestBody)
            .then(jsonEncoder.encodePromise)
            .map(reissueRequest)
            .then(urlSession.httpRequest)
            .then(jsonDecoder.decode)
            .then(certificateReissueRepositoryResponse)
    }

    private func compressAndEncode(_ dgcs: [DigitalGreenCertificate]) -> Promise<[String]> {
        let promises = dgcs.map(compressAndEncode)
        return when(fulfilled: promises)
    }

    private func reissueRequest(_ body: Data) -> URLRequest {
        var request = URLRequest(url: reissueURL)
        request.httpMethod = Constants.httpPostMethod
        request.httpBody = body
        return request
    }

    private func compressAndEncode(dgc: DigitalGreenCertificate) -> Promise<String> {
        jsonEncoder
            .encodePromise(dgc)
            .then(\.compressed)
            .then(\.base45Encode)
            .map { $0.addPrefix() }
    }

    private func certificateReissueRepositoryResponse(_ response: [CertificateReissueResponse]) -> Promise<CertificateReissueRepositoryResponse> {
        let promises = response.map(digitalGreenCertificate)
        return when(fulfilled: promises)
    }

    private func digitalGreenCertificate(from response: CertificateReissueResponse) -> Promise<DigitalGreenCertificate> {
        response.certificate
            .stripPrefix()
            .decodedBase45
            .then(\.decompressed)
            .then(jsonDecoder.decode)
    }
}

private extension Array where Element == String {
    var certificateReissueRequestBody: CertificateReissueRequestBody {
        .init(action: .renew, certificates: self)
    }
}

private extension JSONEncoder {
    func encodePromise<T: Encodable>(_ value: T) -> Promise<Data> {
        var promise: Promise<Data>
        do {
            let data = try encode(value)
            promise = .value(data)
        } catch {
            promise = .init(error: CertificateReissueError.encoder(error))
        }
        return promise
    }
}

private extension JSONDecoder {
    func decode<T: Decodable>(_ data: Data) -> Promise<T> {
        var promise: Promise<T>
        do {
            let value = try decode(T.self, from: data)
            promise = .value(value)
        } catch {
            promise = .init(error: CertificateReissueError.decoder(error))
        }
        return promise
    }
}
