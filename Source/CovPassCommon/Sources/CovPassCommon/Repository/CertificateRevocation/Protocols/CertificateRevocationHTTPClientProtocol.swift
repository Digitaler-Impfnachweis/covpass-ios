//
//  CertificateRevocationHTTPClientProtocol.swift
//  
//
//  Created by Thomas Kuleßa on 22.03.22.
//

import Foundation
import PromiseKit

public typealias KID = [UInt8]
public typealias CertificateRevocationHash = [UInt8]
public typealias CertificateRevocationIndexListResponse = NSDictionary
public typealias CertificateRevocationChunkListResponse = [CertificateRevocationHash]

public protocol CertificateRevocationHTTPClientProtocol {
    /// Request the top-level `kid.lst`.
    func getKIDList() -> Promise<CertificateRevocationKIDListResponse>

    /// Request the top-level `index.lst`.
    func getIndexList() -> Promise<CertificateRevocationIndexListResponse>

    /// Request the `index.lst` for a given key identifier.
    /// - Parameters:
    ///   - kid: The key identifier.
    /// - Returns: The `index.lst` JSON dictionary.
    func getIndexList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<CertificateRevocationIndexListByKIDResponse>

    /// Request the HTTP headers of`index.lst` for a given key identifier.
    /// - Parameters:
    ///   - kid: The key identifier.
    /// - Returns: Fulfills, if request was successful (HTTP 2xx).
    func headIndexList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void>

    /// Request the`chunk.lst` for a given key identifier.
    /// - Parameters:
    ///   - kid: The key identifier.
    /// - Returns: The `chunk.lst` array.
    func getChunkList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<CertificateRevocationChunkListResponse>

    /// Request the`chunk.lst` for a given key identifier. Results can be narrowed down by providing
    /// first bytes of the hash.
    /// - Parameters:
    ///   - kid: The key identifier.
    ///   - byte1: First byte of the hash. Can me found on second level of `getIndexList` response.
    ///   - byte2: Second byte of the hash. Can me found on third level of `getIndexList` response.
    /// - Returns: The `chunk.lst` array.
    func getChunkList(kid: KID, hashType: CertificateRevocationHashType, byte1: UInt8, byte2: UInt8?) -> Promise<CertificateRevocationChunkListResponse>

    /// Request the HTTP headers of`chunk.lst` for a given key identifier.
    /// - Parameters:
    ///   - kid: The key identifier.
    /// - Returns: Fullfills, if there are results for `byte1` and `byte2`,
    func headChunkList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void>

    /// Request the HTTP headers of`chunk.lst` for a given key identifier. Results can be narrowed down
    /// by providing first bytes of the hash.
    /// - Parameters:
    ///   - kid: The key identifier.
    ///   - byte1: First byte of the hash. Can me found on second level of `getIndexList` response.
    ///   - byte2: Second byte of the hash. Can me found on third level of `getIndexList` response.
    /// - Returns: Fullfills, if there are results for `byte1` and `byte2`,
    func headChunkList(kid: KID, hashType: CertificateRevocationHashType, byte1: UInt8, byte2: UInt8?) -> Promise<Void>
}

public enum CertificateRevocationHashType: UInt8, CaseIterable {
    case signature = 0x0a
    case uci = 0x0b
    case countryCodeUCI = 0x0c
}

