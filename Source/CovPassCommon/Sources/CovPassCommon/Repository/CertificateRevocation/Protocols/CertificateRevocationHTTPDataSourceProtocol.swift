//
//  CertificateRevocationHTTPDataSource.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit

public protocol CertificateRevocationHTTPDataSourceProtocol: CertificateRevocationDataSourceProtocol {
    /// Request the top-level `kid.lst`.
    /// - Parameters:
    ///    - httpHeaders: Set these headers on the request.
    /// - Returns: The KID list response, or a Promise error. If kid list is empty, a HTTP 404 error is
    ///            returned. If the HTTP headers contain a `If-Modified-Since` header and the
    ///            server returns HTTP 304 (Not Modifled) the response might be `nil`.
    func getKIDList(httpHeaders: [String: String?]) -> Promise<CertificateRevocationKIDListResponse?>

    /// Request the `index.lst` for a given key identifier.
    /// - Parameters:
    ///   - kid: The key identifier.
    ///   - hashType: type of the hash to use for request.
    ///   - httpHeaders: Set these headers on the request.
    /// - Returns: The `index.lst` JSON dictionary.  If the HTTP headers contain a
    ///            `If-Modified-Since` header and the server returns HTTP 304 (Not Modifled)
    ///            the response might be `nil`.
    func getIndexList(kid: KID, hashType: CertificateRevocationHashType, httpHeaders: [String: String?]) -> Promise<CertificateRevocationIndexListByKIDResponse?>

    /// Request the`chunk.lst` for a given key identifier and a hash type.
    /// - Parameters:
    ///   - kid: The key identifier.
    ///   - hashType: The type of the hash to lookup.
    ///   - httpHeaders: Set these headers on the request.
    /// - Returns: The `chunk.lst` array. If the HTTP headers contain a
    ///            `If-Modified-Since` header and the server returns HTTP 304 (Not Modifled)
    ///            the response might be `nil`.
    func getChunkList(kid: KID, hashType: CertificateRevocationHashType, httpHeaders: [String: String?]) -> Promise<CertificateRevocationChunkListResponse?>
}
