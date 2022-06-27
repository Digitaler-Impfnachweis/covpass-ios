//
//  CertificateRevocationHTTPClientMock.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import Foundation
import PromiseKit
import XCTest

class CertificateRevocationHTTPClientMock: CertificateRevocationHTTPClientProtocol {
    var getKIDListError: Error?
    var getIndexListError: Error?
    var optionsIndexListError: Error?
    var getChunkListError: Error?
    var optionsChunkListError: Error?

    var kidListResponse = NSDictionary.validKidListResponse()
    var indexListResponse = NSDictionary.validIndexListResponse()
    var chunkListResponse: CertificateRevocationChunkListResponse = .chunkListResponse()

    var getKIDListExpectation = XCTestExpectation(description: "getKIDListExpectation")
    var getIndexListExpectation = XCTestExpectation(description: "getIndexListExpectation")
    var optionsIndexListExpectation = XCTestExpectation(description: "optionsIndexListExpectation")
    var getChunkListExpectation = XCTestExpectation(description: "getChunkListExpectation")
    var optionsChunkListExpectation = XCTestExpectation(description: "optionsChunkListExpectation")

    func getKIDList() -> Promise<CertificateRevocationKIDListResponse> {
        getKIDListExpectation.fulfill()
        if let error = getKIDListError {
            return .init(error: error)
        }
        return try! .value(CertificateRevocationKIDListResponse(with: kidListResponse))
    }

    func getIndexList() -> Promise<CertificateRevocationIndexListResponse> {
        getIndexListExpectation.fulfill()
        if let error = getIndexListError {
            return .init(error: error)
        }
        return .value(indexListResponse)
    }

    func getIndexList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<CertificateRevocationIndexListByKIDResponse> {
        getIndexListExpectation.fulfill()
        if let error = getIndexListError {
            return .init(error: error)
        }
        return try! .value(CertificateRevocationIndexListByKIDResponse(with: indexListResponse))
    }

    func headIndexList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void> {
        optionsIndexListExpectation.fulfill()
        if let error = optionsIndexListError {
            return .init(error: error)
        }
        return .value
    }

    func getChunkList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<CertificateRevocationChunkListResponse> {
        getChunkListExpectation.fulfill()
        if let error = getChunkListError {
            return .init(error: error)
        }
        return .value(chunkListResponse)
    }

    func headChunkList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void> {
        optionsChunkListExpectation.fulfill()
        if let error = optionsChunkListError {
            return .init(error: error)
        }
        return .value
    }

    func getChunkList(kid: KID, hashType: CertificateRevocationHashType, byte1: UInt8, byte2: UInt8?) -> Promise<CertificateRevocationChunkListResponse> {
        getChunkListExpectation.fulfill()
        if let error = getChunkListError {
            return .init(error: error)
        }
        return .value(chunkListResponse)
    }

    func headChunkList(kid: KID, hashType: CertificateRevocationHashType, byte1: UInt8, byte2: UInt8?) -> Promise<Void> {
        optionsChunkListExpectation.fulfill()
        if let error = optionsChunkListError {
            return .init(error: error)
        }
        return .value
    }
}

extension CertificateRevocationChunkListResponse {
    static func chunkListResponse() -> Self {
        [
            [0xa6, 0xb8, 0xa0, 0x1b, 0x67, 0x03, 0x0f, 0x32, 0xe0, 0xe3, 0xd7, 0x05, 0x2a, 0x71, 0xa6, 0x88],
            [0xbc, 0x54, 0x2e, 0xd6, 0x50, 0x62, 0xe7, 0x03, 0x4e, 0xe4, 0x24, 0xbf, 0xde, 0x50, 0xa7, 0xf3],
            [0x97, 0x22, 0x08, 0x27, 0xfe, 0x3c, 0x03, 0x23, 0x73, 0x78, 0x17, 0xfd, 0xd1, 0x3d, 0x6e, 0x4e]
        ]
    }
}
