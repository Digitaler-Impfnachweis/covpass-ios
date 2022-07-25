//
//  CertificateRevocationHTTPDataSource.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import Security

enum HTTPHeader {
    static let ifModifiedSince = "If-Modified-Since"
    static let lastModified = "Last-Modified"
}

private enum Constants {
    static let kidListPath = "/kid.lst"
    static let indexListPath = "/index.lst"
    static let indexListPathForKID = "/%@%02x/index.lst"
    static let chunkListPathForKID = "/%@%02x%@%@/chunk.lst"
    static let httpGetMethod = "GET"
    static let httpHeadMethod = "HEAD"
    static let httpOptionsMethod = "OPTIONS"
}

public class CertificateRevocationHTTPDataSource: CertificateRevocationHTTPDataSourceProtocol {
    private let httpClient: HTTPClientProtocol
    private let baseURL: URL
    private let secKey: SecKey
    private lazy var indexListGetRequest: URLRequest = {
        var request = URLRequest(
            url: self.baseURL.appendingPathComponent(Constants.indexListPath)
        )
        request.httpMethod = Constants.httpGetMethod
        return request
    }()

    public init(baseURL: URL, httpClient: HTTPClientProtocol, secKey: SecKey) {
        self.baseURL = baseURL
        self.httpClient = httpClient
        self.secKey = secKey
    }

    public func getKIDList() -> Promise<CertificateRevocationKIDListResponse> {
        getKIDList(httpHeaders: [:])
            .then(failIfResponseIsNil)
    }

    public func getKIDList(httpHeaders: [String: String?]) -> Promise<CertificateRevocationKIDListResponse?> {
        httpClient
            .httpRequest(kidListGetRequest(httpHeaders: httpHeaders))
            .then { response -> Promise<CertificateRevocationKIDListResponse?> in
                if response.httpURLResponse.statusCode == HTTPStatusCode.notModified {
                    return .value(nil)
                }
                let lastModified = response.httpURLResponse.value(for: HTTPHeader.lastModified)
                return self.responseDataOrFailIfNil(response)
                    .then(self.verifiedCborDictionary)
                    .map {
                        try CertificateRevocationKIDListResponse(
                            with: $0,
                            lastModified: lastModified
                        )
                    }
            }
    }

    private func kidListGetRequest(httpHeaders: [String: String?]) -> URLRequest {
        var request = URLRequest(
            url: self.baseURL.appendingPathComponent(Constants.kidListPath)
        )
        request.httpMethod = Constants.httpGetMethod
        request.setHTTPHeaders(httpHeaders)
        return request
    }

    private func failIfResponseIsNil<ResponseType>(_ response: ResponseType?) -> Promise<ResponseType> {
        guard let response = response else {
            return .init(error: CertificateRevocationDataSourceError.response)
        }
        return .value(response)
    }

    private func responseDataOrFailIfNil(_ response: HTTPClientResponse) -> Promise<Data> {
        guard let data = response.data else {
            return .init(error: CertificateRevocationDataSourceError.response)
        }
        return .value(data)
    }

    private func verifiedCborDictionary(_ data: Data) -> Promise<NSDictionary> {
        CoseSign1Message
            .promise(data: data)
            .then(verify)
            .map {
                try $0.toJSON()
            }
            .map {
                try JSONSerialization.jsonObject(with: $0)
            }
            .then(dictionary(json:))
    }

    private func verify(_ coseSign1Message: CoseSign1Message) -> Promise<CoseSign1Message> {
        do {
            let verified = try secKey.verify(coseSign1Message)
            return verified ? .value(coseSign1Message) : .init(error: HCertError.verifyError)
        } catch {
            return .init(error: error)
        }
    }

    private func dictionary(json: Any) -> Promise<NSDictionary> {
        guard let dictionary = json as? NSDictionary else {
            return .init(error: CertificateRevocationDataSourceError.cbor)
        }
        return .value(dictionary)
    }

    public func getIndexList() -> Promise<CertificateRevocationIndexListResponse> {
        httpClient
            .httpRequest(indexListGetRequest)
            .then(responseDataOrFailIfNil)
            .then(verifiedCborDictionary)
    }

    public func getIndexList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<CertificateRevocationIndexListByKIDResponse> {
        getIndexList(kid: kid, hashType: hashType, httpHeaders: [:])
            .then(failIfResponseIsNil)
    }

    public func getIndexList(kid: KID, hashType: CertificateRevocationHashType, httpHeaders: [String: String?]) -> Promise<CertificateRevocationIndexListByKIDResponse?> {
        httpClient
            .httpRequest(
                indexListRequest(
                    kid: kid,
                    hashType: hashType,
                    httpMethod: Constants.httpGetMethod,
                    httpHeaders: httpHeaders
                )
            )
            .then { response -> Promise<CertificateRevocationIndexListByKIDResponse?> in
                if response.httpURLResponse.statusCode == HTTPStatusCode.notModified {
                    return .value(nil)
                }
                let lastModified = response.httpURLResponse.value(
                    for: HTTPHeader.lastModified
                )
                return self.responseDataOrFailIfNil(response)
                    .then(self.verifiedCborDictionary)
                    .map {
                        try CertificateRevocationIndexListByKIDResponse(
                            with: $0,
                            lastModified: lastModified
                        )
                    }
            }
    }

    private func indexListRequest(kid: KID, hashType: CertificateRevocationHashType, httpMethod: String, httpHeaders: [String: String?] = [:]) -> URLRequest {
        let path = String(
            format: Constants.indexListPathForKID,
            kid.toHexString(),
            hashType.rawValue
        )
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = httpMethod
        request.setHTTPHeaders(httpHeaders)
        return request
    }

    public func headIndexList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void> {
        httpClient
            .httpRequest(
                indexListRequest(
                    kid: kid,
                    hashType: hashType,
                    httpMethod: Constants.httpHeadMethod
                )
            )
            .asVoid()
    }

    public func getChunkList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<CertificateRevocationChunkListResponse> {
        getChunkList(kid: kid, hashType: hashType, httpHeaders: [:])
            .then(failIfResponseIsNil)
    }

    public func getChunkList(kid: KID, hashType: CertificateRevocationHashType, httpHeaders: [String : String?]) -> Promise<CertificateRevocationChunkListResponse?> {
        httpClient
            .httpRequest(
                chunkListRequest(
                    kid: kid,
                    hashType: hashType,
                    httpMethod: Constants.httpGetMethod,
                    httpHeaders: httpHeaders
                )
            )
            .then { response -> Promise<CertificateRevocationChunkListResponse?> in
                if response.httpURLResponse.statusCode == HTTPStatusCode.notModified {
                    return .value(nil)
                }
                let lastModified = response.httpURLResponse.value(
                    for: HTTPHeader.lastModified
                )
                return self.responseDataOrFailIfNil(response)
                    .then(self.verifiedCborArray)
                    .map { hashes in
                        CertificateRevocationChunkListResponse(
                            hashes: hashes,
                            lastModified: lastModified
                        )
                    }
            }
    }

    private func chunkListRequest(
        kid: KID,
        hashType: CertificateRevocationHashType,
        httpMethod: String,
        httpHeaders: [String: String?] = [:]
    ) -> URLRequest {
        let path = String(
            format: Constants.chunkListPathForKID,
            kid.toHexString(),
            hashType.rawValue,
            "",
            ""
        )
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = httpMethod
        request.setHTTPHeaders(httpHeaders)
        return request
    }

    public func getChunkList(kid: KID, hashType: CertificateRevocationHashType, byte1: UInt8, byte2: UInt8?) -> Promise<CertificateRevocationChunkListResponse> {
        httpClient
            .httpRequest(
                chunkListRequest(
                    kid: kid,
                    hashType: hashType,
                    httpMethod: Constants.httpGetMethod,
                    byte1: byte1,
                    byte2: byte2
                )
            )
            .then(responseDataOrFailIfNil)
            .then(verifiedCborArray)
            .map { hashes in
                CertificateRevocationChunkListResponse(hashes: hashes)
            }
    }

    private func chunkListRequest(
        kid: KID,
        hashType: CertificateRevocationHashType,
        httpMethod: String,
        byte1: UInt8,
        byte2: UInt8?
    ) -> URLRequest {
        var byte2Path = ""
        if let byte2 = byte2 {
            byte2Path = .init(format:"/%02x", byte2)
        }
        let path = String(
            format: Constants.chunkListPathForKID,
            kid.toHexString(),
            hashType.rawValue,
            String(format:"/%02x", byte1),
            byte2Path
        )
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = httpMethod
        return request
    }

    private func verifiedCborArray(_ data: Data) -> Promise<[CertificateRevocationHash]> {
        CoseSign1Message
            .promise(data: data)
            .then(verify)
            .map {
                try $0.toJSON()
            }
            .map {
                try JSONSerialization.jsonObject(with: $0)
            }
            .then(array(json:))
    }

    private func array(json: Any) -> Promise<[CertificateRevocationHash]> {
        guard let array = json as? [CertificateRevocationHash] else {
            return .init(error: CertificateRevocationDataSourceError.cbor)
        }
        return .value(array)
    }

    public func headChunkList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void> {
        httpClient
            .httpRequest(
                chunkListRequest(
                    kid: kid,
                    hashType: hashType,
                    httpMethod: Constants.httpHeadMethod
                )
            )
            .asVoid()
    }

    public func headChunkList(kid: KID, hashType: CertificateRevocationHashType, byte1: UInt8, byte2: UInt8?) -> Promise<Void> {
        httpClient
            .httpRequest(
                chunkListRequest(
                    kid: kid,
                    hashType: hashType,
                    httpMethod: Constants.httpHeadMethod,
                    byte1: byte1,
                    byte2: byte2
                )
            )
            .asVoid()
    }
}

private extension URLRequest {
    mutating func setHTTPHeaders(_ headers: [String: String?]) {
        headers.forEach { key, value in
            setValue(value, forHTTPHeaderField: key)
        }
    }
}

private extension HTTPURLResponse {
    func value(for header: String) -> String? {
        let headerValue: String?
        if #available(iOS 13.0, *) {
            headerValue = value(forHTTPHeaderField: header)
        } else {
            headerValue = allHeaderFields[header] as? String
        }
        return headerValue
    }
}
