//
//  CertificateRevocationIndexListResponse.swift
//  
//
//  Created by Thomas Kuleßa on 28.03.22.
//

import Foundation

public struct CertificateRevocationIndexListByKIDResponse {
    private let byte1Hashes: Byte1ValueDictionary
    init(with dictionary: NSDictionary) throws {
        byte1Hashes = try dictionary.hashDictionary()
    }

    public func contains(_ byte1: UInt8) -> Bool {
        byte1Hashes[byte1] != nil
    }

    public func contains(_ byte1: UInt8, _ byte2: UInt8) -> Bool {
        guard let byte2hashes = byte1Hashes[byte1]?.hashes else { return false }
        return byte2hashes[byte2] != nil
    }
}

private typealias Byte1ValueDictionary = Dictionary<UInt8, Byte1ValueType>
private typealias Byte2ValueDictionary = Dictionary<UInt8, Byte2ValueType>

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
        try forEach { (key, value) in
            guard let stringKey = key as? String,
                  let byteKey = UInt8(stringKey, radix: 16),
                  let value = value as? Array<Any>,
                  value.count > 2,
                  let dictionary = value[2] as? NSDictionary
            else {
                throw CertificateRevocationHTTPClientError.cbor
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
        try forEach { (key, value) in
            guard let stringKey = key as? String,
                  let byteKey = UInt8(stringKey, radix: 16),
                  let value = value as? Array<Any>,
                  value.count > 1
            else {
                throw CertificateRevocationHTTPClientError.cbor
            }
            let timestamp = (value[0] as? TimeInterval) ?? 0
            let hashCount = (value[1] as? Int) ?? 0
            result[byteKey] = .init(timestamp: timestamp, hashCount: hashCount)
        }
        return result
    }
}
