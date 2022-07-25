//
//  CertificateRevocationDataSourceMock.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import Foundation
import PromiseKit
import XCTest

class CertificateRevocationDataSourceMock: CertificateRevocationHTTPDataSourceProtocol, CertificateRevocationFilessystemDataSourceProtocol {
    var kidListLastModified: String?
    var indexListLastModified: String?
    var chunkListLastModified: String?
    
    var getKIDListError: Error?
    var getIndexListError: Error?
    var optionsIndexListError: Error?
    var getChunkListError: Error?
    var optionsChunkListError: Error?
    var putKIDListError: Error?
    var putIndexListError: Error?
    var putChunkListError: Error?

    var kidListResponse: NSDictionary? = NSDictionary.validKidListResponse()
    var indexListResponse: NSDictionary? = NSDictionary.validIndexListResponse()
    var chunkListResponse: CertificateRevocationChunkListResponse? = .chunkListResponse()
    var kidListLastModifiedResponseDelay: TimeInterval = 0

    private(set) var receivedKIDListResponse: CertificateRevocationKIDListResponse?
    private(set) var receivedIndexListResponses: [CertificateRevocationIndexListByKIDResponse] = []
    private(set) var receivedChunkListResponses: [CertificateRevocationChunkListResponse] = []
    private(set) var receivedIndexListHashTypes: [CertificateRevocationHashType] = []
    private(set) var receivedChunkListHashTypes: [CertificateRevocationHashType] = []
    private(set) var receivedGetChunkListHTTPHeaders = [String: String?]()
    private(set) var receivedGetIndexListHTTPHeaders = [String: String?]()
    private(set) var receivedGetKIDListHTTPHeaders = [String: String?]()

    let getKIDListExpectation = XCTestExpectation(description: "getKIDListExpectation")
    let getIndexListExpectation = XCTestExpectation(description: "getIndexListExpectation")
    let optionsIndexListExpectation = XCTestExpectation(description: "optionsIndexListExpectation")
    let getChunkListExpectation = XCTestExpectation(description: "getChunkListExpectation")
    let optionsChunkListExpectation = XCTestExpectation(description: "optionsChunkListExpectation")
    let deleteAllExpectation = XCTestExpectation(description: "deleteAllExpectation")
    let getKIDListLastModifiedExpectation = XCTestExpectation(description: "getKIDListLastModifiedExpectation")
    let putKIDListExpectation = XCTestExpectation(description: "putKIDListExpectation")
    let getIndexListLastModifiedExpectation = XCTestExpectation(description: "getIndexListLastModifiedExpectation")
    let putIndexListExpectation = XCTestExpectation(description: "putIndexListExpectation")
    let getChunkListLastModifiedExpectation = XCTestExpectation(description: "getChunkListLastModifiedExpectation")
    let putChunkListExpectation = XCTestExpectation(description: "putChunkListExpectation")

    func getKIDList() -> Promise<CertificateRevocationKIDListResponse> {
        getKIDList(httpHeaders: [:])
            .then { response -> Promise<CertificateRevocationKIDListResponse> in
                if let response = response {
                    return .value(response)
                }
                return .init(error: CertificateRevocationDataSourceError.notFound)
            }
    }

    func getIndexList() -> Promise<CertificateRevocationIndexListResponse> {
        getIndexListExpectation.fulfill()
        if let error = getIndexListError {
            return .init(error: error)
        }
        return .value(indexListResponse!)
    }

    func getIndexList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<CertificateRevocationIndexListByKIDResponse> {
        getIndexList(kid: kid, hashType: hashType, httpHeaders: [:])
            .then { response -> Promise<CertificateRevocationIndexListByKIDResponse> in
                if let response = response {
                    return .value(response)
                }
                return .init(error: CertificateRevocationDataSourceError.notFound)
            }
    }

    func headIndexList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void> {
        optionsIndexListExpectation.fulfill()
        if let error = optionsIndexListError {
            return .init(error: error)
        }
        return .value
    }

    func getChunkList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<CertificateRevocationChunkListResponse> {
        getChunkList(kid: kid, hashType: hashType, httpHeaders: [:])
            .then { response -> Promise<CertificateRevocationChunkListResponse> in
                if let response = response {
                    return .value(response)
                }
                return .init(error: CertificateRevocationDataSourceError.notFound)
            }
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
        return .value(chunkListResponse!)
    }

    func headChunkList(kid: KID, hashType: CertificateRevocationHashType, byte1: UInt8, byte2: UInt8?) -> Promise<Void> {
        optionsChunkListExpectation.fulfill()
        if let error = optionsChunkListError {
            return .init(error: error)
        }
        return .value
    }

    func getKIDList(httpHeaders: [String : String?]) -> Promise<CertificateRevocationKIDListResponse?> {
        receivedGetKIDListHTTPHeaders = httpHeaders
        getKIDListExpectation.fulfill()
        if let error = getKIDListError {
            return .init(error: error)
        }
        if let kidListResponse = kidListResponse {
            return try! .value(CertificateRevocationKIDListResponse(with: kidListResponse))
        }
        return .value(nil)
    }

    func getIndexList(kid: KID, hashType: CertificateRevocationHashType, httpHeaders: [String : String?]) -> Promise<CertificateRevocationIndexListByKIDResponse?> {
        receivedIndexListHashTypes.append(hashType)
        receivedGetIndexListHTTPHeaders = httpHeaders
        getIndexListExpectation.fulfill()
        if let error = getIndexListError {
            return .init(error: error)
        }
        if let indexListResponse = indexListResponse {
            return try! .value(CertificateRevocationIndexListByKIDResponse(with: indexListResponse))
        }
        return .value(nil)
    }

    func getChunkList(kid: KID, hashType: CertificateRevocationHashType, httpHeaders: [String : String?]) -> Promise<CertificateRevocationChunkListResponse?> {
        receivedChunkListHashTypes.append(hashType)
        receivedGetChunkListHTTPHeaders = httpHeaders
        getChunkListExpectation.fulfill()
        if let error = getChunkListError {
            return .init(error: error)
        }
        return .value(chunkListResponse)
    }

    func getKIDListLastModified() -> Guarantee<String?> {
        after(seconds: kidListLastModifiedResponseDelay)
            .then {
                self.getKIDListLastModifiedExpectation.fulfill()
                return .value(self.kidListLastModified)
            }
    }

    func getIndexListLastModified(kid: KID, hashType: CertificateRevocationHashType) -> Guarantee<String?> {
        getIndexListLastModifiedExpectation.fulfill()
        return .value(indexListLastModified)
    }


    func getChunkListLastModified(kid: KID, hashType: CertificateRevocationHashType) -> Guarantee<String?> {
        getChunkListLastModifiedExpectation.fulfill()
        return .value(chunkListLastModified)
    }

    func putKIDList(_ kidList: CertificateRevocationKIDListResponse) -> Promise<Void> {
        receivedKIDListResponse = kidList
        putKIDListExpectation.fulfill()
        if let error = putKIDListError {
            return .init(error: error)
        }
        return .value
    }

    func putIndexList(_ indexList: CertificateRevocationIndexListByKIDResponse, kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void> {
        putIndexListExpectation.fulfill()
        receivedIndexListResponses.append(indexList)
        if let error = putIndexListError {
            return .init(error: error)
        }
        return .value
    }

    func putChunkList(_ chunkList: CertificateRevocationChunkListResponse, kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void> {
        receivedChunkListResponses.append(chunkList)
        receivedChunkListHashTypes.append(hashType)
        putChunkListExpectation.fulfill()
        if let error = putChunkListError {
            return .init(error: error)
        }
        return .value
    }

    func deleteAll() -> Promise<Void> {
        deleteAllExpectation.fulfill()
        return .value
    }
}

extension CertificateRevocationChunkListResponse {
    static func chunkListResponse() -> Self {
        .init(
            hashes: [
                [0xa6, 0xb8, 0xa0, 0x1b, 0x67, 0x03, 0x0f, 0x32, 0xe0, 0xe3, 0xd7, 0x05, 0x2a, 0x71, 0xa6, 0x88],
                [0xbc, 0x54, 0x2e, 0xd6, 0x50, 0x62, 0xe7, 0x03, 0x4e, 0xe4, 0x24, 0xbf, 0xde, 0x50, 0xa7, 0xf3],
                [0x97, 0x22, 0x08, 0x27, 0xfe, 0x3c, 0x03, 0x23, 0x73, 0x78, 0x17, 0xfd, 0xd1, 0x3d, 0x6e, 0x4e]
            ]
        )
    }
}
