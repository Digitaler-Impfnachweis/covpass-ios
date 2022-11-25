//
//  CertificateRevocationFilesystemDataSource.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

private enum Constants {
    static let lastModified = "last-modified"
    static let kidListPath = "/kid.lst"
    static let indexListDirectory = "/%@%02x/"
    static let indexListFilename = "index.lst"
    static let indexListLastModifiedForKID = "/%@%02x/"
    static let chunkListDirectory = "/%@%02x/"
    static let chunkListFilename = "chunk.lst"
}

public final class CertificateRevocationFilesystemDataSource: CertificateRevocationFilessystemDataSourceProtocol {
    private let fileManager: FileManager
    private let baseURL: URL
    private let kidListPath: String
    private let kidListLastModifiedPath: String
    private let indexListPath: String
    private let indexListLastModifiedPath: String
    private let chunkListPath: String
    private let chunkListLastModifiedPath: String

    public init(baseURL: URL, fileManager: FileManager) {
        self.baseURL = baseURL
        self.fileManager = fileManager

        let kidListURL = baseURL.appendingPathComponent(Constants.kidListPath)
        kidListPath = kidListURL.path
        kidListLastModifiedPath = kidListURL
            .appendingPathExtension(Constants.lastModified)
            .path

        let indexListDirectoryURL = baseURL
            .appendingPathComponent(Constants.indexListDirectory, isDirectory: true)
        indexListPath = indexListDirectoryURL
            .appendingPathComponent(Constants.indexListFilename, isDirectory: false)
            .path
        indexListLastModifiedPath = indexListDirectoryURL
            .appendingPathComponent(Constants.indexListFilename, isDirectory: false)
            .appendingPathExtension(Constants.lastModified)
            .path

        let chunkListDirectoryURL = baseURL
            .appendingPathComponent(Constants.chunkListDirectory, isDirectory: true)
        chunkListPath = chunkListDirectoryURL
            .appendingPathComponent(Constants.chunkListFilename, isDirectory: false)
            .path
        chunkListLastModifiedPath = chunkListDirectoryURL
            .appendingPathComponent(Constants.chunkListFilename, isDirectory: false)
            .appendingPathExtension(Constants.lastModified)
            .path
    }

    public func getKIDListLastModified() -> Guarantee<String?> {
        loadString(path: kidListLastModifiedPath)
    }

    private func loadString(path: String) -> Guarantee<String?> {
        guard let data = fileManager.contents(atPath: path),
              let lastModified = String(data: data, encoding: .utf8)
        else {
            return .value(nil)
        }
        return .value(lastModified)
    }

    public func putKIDList(_ kidList: CertificateRevocationKIDListResponse) -> Promise<Void> {
        fileManager
            .createDirectoryPromise(at: baseURL, withIntermediateDirectories: true)
            .then {
                self.writeDictionary(
                    kidList.rawDictionary,
                    atPath: self.kidListPath
                )
            }
            .then {
                self.fileManager.createFilePromise(
                    atPath: self.kidListLastModifiedPath,
                    contents: kidList.lastModified?.data(using: .utf8)
                )
            }
    }

    private func writeDictionary(_ dictionary: NSDictionary, atPath: String) -> Promise<Void> {
        do {
            let contents = try PropertyListSerialization.data(
                fromPropertyList: dictionary,
                format: .xml,
                options: 0
            )
            return fileManager.createFilePromise(
                atPath: atPath,
                contents: contents
            )
        } catch {
            return .init(error: error)
        }
    }

    public func getIndexListLastModified(kid: KID, hashType: CertificateRevocationHashType) -> Guarantee<String?> {
        let path = String(format: indexListLastModifiedPath, kid.toHexString(), hashType.rawValue)

        return loadString(path: path)
    }

    public func putIndexList(_ indexList: CertificateRevocationIndexListByKIDResponse, kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void> {
        let directory = String(format: Constants.indexListDirectory, kid.toHexString(), hashType.rawValue)
        let url = baseURL.appendingPathComponent(directory)

        return fileManager
            .createDirectoryPromise(at: url, withIntermediateDirectories: true)
            .then {
                self.writeDictionary(
                    indexList.rawDictionary,
                    atPath: String(
                        format: self.indexListPath,
                        kid.toHexString(), hashType.rawValue
                    )
                )
            }
            .then {
                self.fileManager.createFilePromise(
                    atPath: String(
                        format: self.indexListLastModifiedPath,
                        kid.toHexString(), hashType.rawValue
                    ),
                    contents: indexList.lastModified?.data(using: .utf8)
                )
            }
    }

    public func getChunkListLastModified(kid: KID, hashType: CertificateRevocationHashType) -> Guarantee<String?> {
        let path = String(format: chunkListLastModifiedPath, kid.toHexString(), hashType.rawValue)

        return loadString(path: path)
    }

    public func putChunkList(_ chunkList: CertificateRevocationChunkListResponse, kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void> {
        let directory = String(format: Constants.chunkListDirectory, kid.toHexString(), hashType.rawValue)
        let url = baseURL.appendingPathComponent(directory)

        return fileManager
            .createDirectoryPromise(at: url, withIntermediateDirectories: true)
            .then {
                self.writeArray(
                    chunkList.hashes,
                    atPath: String(
                        format: self.chunkListPath,
                        kid.toHexString(), hashType.rawValue
                    )
                )
            }
            .then {
                self.fileManager.createFilePromise(
                    atPath: String(
                        format: self.chunkListLastModifiedPath,
                        kid.toHexString(), hashType.rawValue
                    ),
                    contents: chunkList.lastModified?.data(using: .utf8)
                )
            }
    }

    private func writeArray(_ array: [Any], atPath: String) -> Promise<Void> {
        do {
            let contents = try JSONSerialization.data(withJSONObject: array, options: [])
            return fileManager.createFilePromise(
                atPath: atPath,
                contents: contents
            )
        } catch {
            return .init(error: error)
        }
    }

    public func deleteAll() -> Promise<Void> {
        do {
            try fileManager.removeItem(at: baseURL)
            return .value
        } catch {
            return .init(error: error)
        }
    }
}

extension CertificateRevocationFilesystemDataSource: CertificateRevocationDataSourceProtocol {
    public func getKIDList() -> Promise<CertificateRevocationKIDListResponse> {
        do {
            let dictionary = try loadDictionary(atPath: kidListPath)
            let response = try CertificateRevocationKIDListResponse(with: dictionary)

            return .value(response)
        } catch {
            return .init(error: error)
        }
    }

    private func loadDictionary(atPath: String) throws -> NSDictionary {
        guard let data = fileManager.contents(atPath: atPath) else {
            throw CertificateRevocationDataSourceError.notFound
        }
        guard let dictionary = try PropertyListSerialization.propertyList(from: data, format: nil) as? NSDictionary else {
            throw CertificateRevocationDataSourceError.response
        }

        return dictionary
    }

    public func getIndexList() -> Promise<CertificateRevocationIndexListResponse> {
        .init(error: CertificateRevocationDataSourceError.unsupported)
    }

    public func getIndexList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<CertificateRevocationIndexListByKIDResponse> {
        do {
            let path = String(format: indexListPath, kid.toHexString(), hashType.rawValue)
            let dictionary = try loadDictionary(atPath: path)
            let response = try CertificateRevocationIndexListByKIDResponse(with: dictionary)

            return .value(response)
        } catch {
            return .init(error: error)
        }
    }

    public func headIndexList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void> {
        let path = String(format: indexListPath, kid.toHexString(), hashType.rawValue)
        if fileManager.fileExists(atPath: path) {
            return .value
        }
        return .init(error: CertificateRevocationDataSourceError.notFound)
    }

    public func getChunkList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<CertificateRevocationChunkListResponse> {
        do {
            let path = String(format: chunkListPath, kid.toHexString(), hashType.rawValue)
            let array: [CertificateRevocationHash] = try loadArray(atPath: path)
            let response = CertificateRevocationChunkListResponse(hashes: array)

            return .value(response)
        } catch {
            return .init(error: error)
        }
    }

    private func loadArray<ArrayType>(atPath: String) throws -> [ArrayType] {
        guard let data = fileManager.contents(atPath: atPath) else {
            throw CertificateRevocationDataSourceError.notFound
        }
        guard let array = try JSONSerialization.jsonObject(with: data) as? [ArrayType] else {
            throw CertificateRevocationDataSourceError.response
        }

        return array
    }

    public func getChunkList(kid: KID, hashType: CertificateRevocationHashType, byte1: UInt8, byte2: UInt8?) -> Promise<CertificateRevocationChunkListResponse> {
        getChunkList(kid: kid, hashType: hashType)
            .then { response -> Promise<CertificateRevocationChunkListResponse> in
                let hashesWithByte1And2Only = response.hashes
                    .filter { $0.starts(with: byte1, byte2: byte2) }
                if hashesWithByte1And2Only.isEmpty {
                    return .init(error: CertificateRevocationDataSourceError.notFound)
                }
                return .value(
                    .init(
                        hashes: hashesWithByte1And2Only,
                        lastModified: response.lastModified
                    )
                )
            }
    }

    public func headChunkList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void> {
        let path = String(format: chunkListPath, kid.toHexString(), hashType.rawValue)
        if fileManager.fileExists(atPath: path) {
            return .value
        }
        return .init(error: CertificateRevocationDataSourceError.notFound)
    }

    public func headChunkList(kid: KID, hashType: CertificateRevocationHashType, byte1: UInt8, byte2: UInt8?) -> Promise<Void> {
        getChunkList(kid: kid, hashType: hashType)
            .map { response in
                response.hashes.contains { $0.starts(with: byte1, byte2: byte2) }
            }
            .then { isContained -> Promise<Void> in
                guard isContained else {
                    return .init(error: CertificateRevocationDataSourceError.notFound)
                }
                return .value
            }
    }
}

private extension CertificateRevocationHash {
    func starts(with byte1: UInt8, byte2: UInt8?) -> Bool {
        let prefix = [byte1, byte2].compactMap { $0 }
        return starts(with: prefix)
    }
}
