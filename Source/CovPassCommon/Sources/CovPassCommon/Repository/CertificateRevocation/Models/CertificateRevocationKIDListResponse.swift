//
//  CertificateRevocationKIDListResponse.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct CertificateRevocationKIDListResponse {
    public let lastModified: String?
    public let rawDictionary: NSDictionary
    private let allKIDs: [KID]
    private let kIDs: [String: KIDListValueType]

    init(with dictionary: NSDictionary, lastModified: String? = nil) throws {
        rawDictionary = dictionary
        self.lastModified = lastModified
        kIDs = try dictionary.kidDictionary()
        self.allKIDs = kIDs.keys.map(\.hexToBytes)
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

    public func kids(with hashType: CertificateRevocationHashType) -> [KID] {
        allKIDs.filter { count($0, hashType: hashType) > 0 }
    }
}

public typealias KIDListValueType = Dictionary<CertificateRevocationHashType, Int>

private extension NSDictionary {
    func kidDictionary() throws -> Dictionary<String, KIDListValueType> {
        var result: [String: KIDListValueType] = [:]
        try forEach { (key, value) in
            guard let stringKey = key as? String,
                  let valueDictionary = value as? NSDictionary else {
                throw CertificateRevocationDataSourceError.cbor
            }
            let resultValue = try valueDictionary.hashTypeDictionary()
            result[stringKey.lowercased()] = resultValue
        }
        return result
    }

    func hashTypeDictionary() throws -> KIDListValueType {
        var result: KIDListValueType = [:]
        try forEach { (key, value) in
            guard let stringKey = key as? String,
                  let intKey = UInt8(stringKey, radix: 16),
                  let hashKey = CertificateRevocationHashType(rawValue: intKey),
                  let value = value as? Int else {
                throw CertificateRevocationDataSourceError.cbor
            }
            result[hashKey] = value
        }
        return result
    }
}

// https://stackoverflow.com/questions/43360747/how-to-convert-hexadecimal-string-to-an-array-of-uint8-bytes-in-swift
private extension StringProtocol {
    var hexToBytes: [UInt8] { .init(hexa) }
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}

