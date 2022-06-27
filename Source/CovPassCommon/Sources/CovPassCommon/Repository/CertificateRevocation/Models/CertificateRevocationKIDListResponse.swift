//
//  CertificateRevocationKIDListResponse.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct CertificateRevocationKIDListResponse {
    private let kIDs: [String: ValueType]

    init(with dictionary: NSDictionary) throws {
        kIDs = try dictionary.kidDictionary()
    }

    public func contains(_ kid: KID) -> Bool {
        kIDs[kid.toHexString()] != nil
    }

    public func count(_ kid: KID, hashType: CertificateRevocationHashType) -> Int {
        let result = kIDs[kid.toHexString()]
        return result?[hashType] ?? 0
    }

    public func hashTypeCounts(_ kid: KID) -> [(CertificateRevocationHashType, Int)] {
        CertificateRevocationHashType
            .allCases
            .map { hashType in
                (hashType, count(kid, hashType: hashType))
            }
            .filter { (_, count) in
                count > 0
            }
            .sorted { count1, count2 in
                count1.1 > count2.1
            }
    }
}

private typealias ValueType = Dictionary<CertificateRevocationHashType, Int>

private extension NSDictionary {
    func kidDictionary() throws -> Dictionary<String, ValueType> {
        var result: [String: ValueType] = [:]
        try forEach { (key, value) in
            guard let stringKey = key as? String,
                  let valueDictionary = value as? NSDictionary else {
                throw CertificateRevocationHTTPClientError.cbor
            }
            let resultValue = try valueDictionary.hashTypeDictionary()
            result[stringKey.lowercased()] = resultValue
        }
        return result
    }

    func hashTypeDictionary() throws -> ValueType {
        var result: ValueType = [:]
        try forEach { (key, value) in
            guard let stringKey = key as? String,
                  let intKey = UInt8(stringKey, radix: 16),
                  let hashKey = CertificateRevocationHashType(rawValue: intKey),
                  let value = value as? Int else {
                throw CertificateRevocationHTTPClientError.cbor
            }
            result[hashKey] = value
        }
        return result
    }
}
