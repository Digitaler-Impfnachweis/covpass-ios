//
//  CertificateRevocationIndexListResponse.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct CertificateRevocationIndexListByKIDResponse {
    let lastModified: String?
    let rawDictionary: NSDictionary
    private let byte1Hashes: Byte1ValueDictionary

    init(with dictionary: NSDictionary, lastModified: String? = nil) throws {
        self.lastModified = lastModified
        rawDictionary = dictionary
        byte1Hashes = try dictionary.hashDictionary()
    }

    func contains(_ byte1: UInt8) -> Bool {
        byte1Hashes[byte1] != nil
    }

    func contains(_ byte1: UInt8, _ byte2: UInt8) -> Bool {
        guard let byte2hashes = byte1Hashes[byte1]?.hashes else { return false }
        return byte2hashes[byte2] != nil
    }
}

private typealias Byte1ValueDictionary = [UInt8: Byte1ValueType]
private typealias Byte2ValueDictionary = [UInt8: Byte2ValueType]

private struct Byte1ValueType {
    let timestamp: TimeInterval
    let hashCount: Int
    let hashes: Byte2ValueDictionary
}

private struct Byte2ValueType {
    let timestamp: TimeInterval
    let hashCount: Int
}

private extension NSDictionary {
    func hashDictionary() throws -> Byte1ValueDictionary {
        var result: Byte1ValueDictionary = [:]
        try forEach { key, value in
            guard let stringKey = key as? String,
                  let byteKey = UInt8(stringKey, radix: 16),
                  let value = value as? [Any],
                  value.count > 2,
                  let dictionary = value[2] as? NSDictionary
            else {
                throw CertificateRevocationDataSourceError.cbor
            }
            let timestamp = (value[0] as? TimeInterval) ?? 0
            let hashCount = (value[1] as? Int) ?? 0
            let hashes = try dictionary.valueDictionary()
            result[byteKey] = .init(timestamp: timestamp, hashCount: hashCount, hashes: hashes)
        }
        return result
    }

    func valueDictionary() throws -> Byte2ValueDictionary {
        var result: Byte2ValueDictionary = [:]
        try forEach { key, value in
            guard let stringKey = key as? String,
                  let byteKey = UInt8(stringKey, radix: 16),
                  let value = value as? [Any],
                  value.count > 1
            else {
                throw CertificateRevocationDataSourceError.cbor
            }
            let timestamp = (value[0] as? TimeInterval) ?? 0
            let hashCount = (value[1] as? Int) ?? 0
            result[byteKey] = .init(timestamp: timestamp, hashCount: hashCount)
        }
        return result
    }
}
