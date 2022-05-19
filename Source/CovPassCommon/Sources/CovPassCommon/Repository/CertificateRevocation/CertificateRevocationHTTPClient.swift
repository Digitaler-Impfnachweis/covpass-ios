//
//  CertificateRevocationHTTPClient.swift
//  
//
//  Created by Thomas Kuleßa on 22.03.22.
//

import Foundation
import PromiseKit
import Security

private enum Constants {
    static let kidListPath = "/kid.lst"
    static let indexListPath = "/index.lst"
    static let indexListPathForKID = "/%@%02x/index.lst"
    static let chunkListPathForKID = "/%@%02x%@%@/chunk.lst"
    static let httpGetMethod = "GET"
    static let httpHeadMethod = "HEAD"
    static let httpOptionsMethod = "OPTIONS"
}

public class CertificateRevocationHTTPClient: CertificateRevocationHTTPClientProtocol {
    private let httpClient: HTTPClientProtocol
    private let baseURL: URL
    private let secKey: SecKey
    private lazy var kidListGetRequest: URLRequest = {
        var request = URLRequest(
            url: self.baseURL.appendingPathComponent(Constants.kidListPath)
        )
        request.httpMethod = Constants.httpGetMethod
        return request
    }()
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
        httpClient
            .httpRequest(kidListGetRequest)
            .then(verifiedCborDictionary)
            .map { try CertificateRevocationKIDListResponse(with: $0) }
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
            return .init(error: CertificateRevocationHTTPClientError.cbor)
        }
        return .value(dictionary)
    }

    public func getIndexList() -> Promise<CertificateRevocationIndexListResponse> {
        httpClient
            .httpRequest(indexListGetRequest)
            .then(verifiedCborDictionary)
    }

    public func getIndexList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<CertificateRevocationIndexListByKIDResponse> {
        httpClient
            .httpRequest(
                indexListRequest(kid: kid, hashType: hashType, httpMethod: Constants.httpGetMethod)
            )
            .then(verifiedCborDictionary)
            .map { try CertificateRevocationIndexListByKIDResponse(with: $0) }
    }

    private func indexListRequest(kid: KID, hashType: CertificateRevocationHashType, httpMethod: String) -> URLRequest {
        let path = String(
            format: Constants.indexListPathForKID,
            kid.toHexString(),
            hashType.rawValue
        )
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = httpMethod
        return request
    }

    public func headIndexList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void> {
        httpClient
            .httpRequest(
                indexListRequest(kid: kid, hashType: hashType, httpMethod: Constants.httpHeadMethod)
            )
            .asVoid()
    }

    public func getChunkList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<CertificateRevocationChunkListResponse> {
        httpClient
            .httpRequest(
                chunkListRequest(
                    kid: kid,
                    hashType: hashType,
                    httpMethod: Constants.httpGetMethod
                )
            )
            .then(verifiedCborArray)
    }

    private func chunkListRequest(
        kid: KID,
        hashType: CertificateRevocationHashType,
        httpMethod: String
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
            .then(verifiedCborArray)
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

    private func verifiedCborArray(_ data: Data) -> Promise<CertificateRevocationChunkListResponse> {
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

    private func array(json: Any) -> Promise<CertificateRevocationChunkListResponse> {
        guard let array = json as? CertificateRevocationChunkListResponse else {
            return .init(error: CertificateRevocationHTTPClientError.cbor)
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

