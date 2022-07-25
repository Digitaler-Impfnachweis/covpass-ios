//
//  CertificateRevocationFilessystemDataSourceProtocol.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

/// The protocol describes a filesystem based data source for revocation info. Additionally to the methods
/// for all revocation info data sources it defines methods to check for last updates and writing of revocation
/// data to the file system.
public protocol CertificateRevocationFilessystemDataSourceProtocol: CertificateRevocationDataSourceProtocol {
    /// Gets the info when the `kid.lst` was last modified.. The string is directly taken from the HTTP
    /// response header `Last-Modified` and can though be used as value for the
    /// `if-modified-since` header for requests.
    /// - Returns: When the list was never downloaded and stored the string is `nil`, otherwise the
    /// date of the last change to the `kid.lst`
    func getKIDListLastModified() -> Guarantee<String?>

    /// Gets the info when the `index.lst` for the `kid` and `hashType` was last modified.
    /// The string is directly taken from the HTTP response header `Last-Modified` and can though be
    /// used as value for the `if-modified-since` header for requests.
    /// - Parameters:
    ///    - kid: The identifier for the key.
    ///    - hashType: The type of hash for the list.
    /// - Returns: When the list was never downloaded and stored the string is `nil`, otherwise the
    /// date of the last change to the `index.lst`
    func getIndexListLastModified(kid: KID, hashType: CertificateRevocationHashType) -> Guarantee<String?>

    /// Gets the info when the `chunk.lst` for the `kid` and `hashType` was last modified.
    /// The string is directly taken from the HTTP response header `Last-Modified` and can though be
    /// used as value for the `if-modified-since` header for requests.
    /// - Parameters:
    ///    - kid: The identifier for the key.
    ///    - hashType: The type of hash for the list.
    /// - Returns: When the list was never downloaded and stored the string is `nil`, otherwise the
    /// date of the last change to the `chunk.lst`
    func getChunkListLastModified(kid: KID, hashType: CertificateRevocationHashType) -> Guarantee<String?>

    /// Stores the `kid.lst` in the file system. Also stores the date of the last modification as needed by
    /// `getKIDListLastModified()`.
    /// - Parameter kidList: The list to store.
    /// - Returns: Success, if the list could be written to the filesystem.
    func putKIDList(_ kidList: CertificateRevocationKIDListResponse) -> Promise<Void>

    /// Stores the `index.lst` in the file system. Also stores the date of the last modification as needed by
    /// `getIndexListLastModified()`.
    /// - Parameters:
    ///   - indexList: The list to store.
    ///   - kid: The identifier for the key.
    ///   - hashType: The type of hash for the list.
    /// - Returns: Success, if the list could be written to the filesystem.
    func putIndexList(_ indexList: CertificateRevocationIndexListByKIDResponse, kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void>

    /// Stores the `chunk.lst` in the file system. Also stores the date of the last modification as needed by
    /// `getChunkListLastModified()`.
    /// - Parameters:
    ///   - chunkList: The list to store.
    ///   - kid: The identifier for the key.
    ///   - hashType: The type of hash for the list.
    /// - Returns: Success, if the list could be written to the filesystem.
    func putChunkList(_ chunkList: CertificateRevocationChunkListResponse, kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void>

    /// Deletes `kid.list`, all `index.list` and all `chunk.list` from the file system.
    /// - Returns: Success, if all data could be deleted.
    func deleteAll() -> Promise<Void>
}
