//
//  CertificateRevocationOfflineServiceTests.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import Foundation
import XCTest

class CertificateRevocationOfflineServiceTests: XCTestCase {
    private var localDataSource: CertificateRevocationDataSourceMock!
    private var remoteDataSource: CertificateRevocationDataSourceMock!
    private var dateProvider: StaticDateProvider!
    private var persistence: MockPersistence!
    private var sut: CertificateRevocationOfflineService!

    override func setUpWithError() throws {
        localDataSource = .init()
        remoteDataSource = .init()
        dateProvider = .init()
        persistence = .init()
        dateProvider.date = .init(timeIntervalSinceReferenceDate: 0)
        sut = .init(
            localDataSource: localDataSource,
            remoteDataSource: remoteDataSource,
            dateProvider: dateProvider,
            persistence: persistence
        )
    }

    override func tearDownWithError() throws {
        localDataSource = nil
        remoteDataSource = nil
        dateProvider = nil
        persistence = nil
        sut = nil
    }

    func testState_default() {
        // When
        let state = sut.state

        // Then
        XCTAssertEqual(state, .idle)
    }

    func testLastSuccessfulUpdate_default() {
        // When
        let date = sut.lastSuccessfulUpdate

        // Then
        XCTAssertNil(date)
    }

    func testLastSuccessfulUpdate_update_success() {
        // Given
        let expectedLastSuccessfulUpdate = Date(timeIntervalSinceReferenceDate: 0)
        sut.update()
        wait(for: [persistence.storeExpectation], timeout: 1)

        // When
        let lastSuccessfulUpdate = sut.lastSuccessfulUpdate

        // Then
        XCTAssertEqual(lastSuccessfulUpdate, expectedLastSuccessfulUpdate)
        XCTAssertEqual(sut.state, .completed)
    }

    func testReset_default() {
        // When
        sut.reset()

        // Then
        XCTAssertEqual(sut.state, .idle)
        XCTAssertNil(sut.lastSuccessfulUpdate)
        wait(for: [localDataSource.deleteAllExpectation], timeout: 1)
    }

    func testReset_while_update_is_running() {
        // Given
        remoteDataSource.getIndexListLastModifiedExpectation.isInverted = true
        localDataSource.kidListLastModifiedResponseDelay = 1.0
        sut.update()
        
        // When
        sut.reset()

        // Then
        XCTAssertEqual(sut.state, .cancelling)
        wait(for: [
            localDataSource.deleteAllExpectation,
            remoteDataSource.getKIDListExpectation,
            persistence.storeExpectation
        ], timeout: 2)
        XCTAssertNil(sut.lastSuccessfulUpdate)
    }

    func testUpdate_called_two_times() {
        // Given
        remoteDataSource.getKIDListExpectation.expectedFulfillmentCount = 1
        sut.update()
        
        // When
        sut.update()

        // Then
        XCTAssertEqual(sut.state, .updating)
        wait(for: [remoteDataSource.getKIDListExpectation], timeout: 1)
    }

    func testUpdate_kid_list_no_local_data_no_error() throws {
        // Given
        localDataSource.kidListLastModified = "XYZ"
        let expectedResponse = try XCTUnwrap(
            CertificateRevocationKIDListResponse(with: .validKidListResponse())
        )
        let expectedLastSuccessfulUpdate = Date(timeIntervalSinceReferenceDate: 0)

        // When
        sut.update()

        // Then
        XCTAssertEqual(sut.state, .updating)
        wait(for: [
            localDataSource.getKIDListLastModifiedExpectation,
            remoteDataSource.getKIDListExpectation,
            localDataSource.putKIDListExpectation,
            persistence.storeExpectation
        ], timeout: 2, enforceOrder: true)
        if let response = localDataSource.receivedKIDListResponse {
            XCTAssertEqual(
                Set<KID>(response.kids(with: .uci)),
                Set<KID>(expectedResponse.kids(with: .uci))
            )
            XCTAssertEqual(
                Set<KID>(response.kids(with: .signature)),
                Set<KID>(expectedResponse.kids(with: .signature))
            )
            XCTAssertEqual(
                Set<KID>(response.kids(with: .countryCodeUCI)),
                Set<KID>(expectedResponse.kids(with: .countryCodeUCI))
            )
        } else {
            XCTFail("Response must not be nil.")
        }
        XCTAssertEqual(
            localDataSource.receivedKIDListResponse?.lastModified,
            expectedResponse.lastModified
        )
        if let isModified = remoteDataSource.receivedGetKIDListHTTPHeaders[HTTPHeader.ifModifiedSince] {
            XCTAssertEqual(isModified, "XYZ")
        } else {
            XCTFail("HTTP header must be present.")
        }
        XCTAssertEqual(persistence.receivedStoreKey, "keyCertificateRevocationServiceLastUpdate")
        if let date = persistence.receivedStoreValue as? Date {
            XCTAssertEqual(date, expectedLastSuccessfulUpdate)
        } else {
            XCTFail("Value must be a date.")
        }
    }

    func testUpdate_kid_list_local_data_not_modified_no_error() {
        // Given
        localDataSource.putKIDListExpectation.isInverted = true
        remoteDataSource.kidListResponse = nil

        // When
        sut.update()

        // Then
        wait(for: [localDataSource.putKIDListExpectation], timeout: 2)
    }

    func testUpdate_kid_list_getKIDListError() {
        // Given
        localDataSource.putKIDListExpectation.isInverted = true
        remoteDataSource.getKIDListError = NSError(domain: "TEST", code: 0)

        // When
        sut.update()

        // Then
        wait(for: [localDataSource.putKIDListExpectation], timeout: 2)
        XCTAssertEqual(sut.state, .error)
    }

    func testUpdate_kid_list_putKIDListError() {
        // Given
        localDataSource.getKIDListExpectation.isInverted = true
        localDataSource.putKIDListError = NSError(domain: "TEST", code: 0)

        // When
        sut.update()

        // Then
        wait(for: [localDataSource.getKIDListExpectation], timeout: 2)
        XCTAssertEqual(sut.state, .error)
    }

    func testUpdate_index_lists_no_local_data_no_error() throws {
        // Given
        let expectedRequests = 7
        localDataSource.indexListLastModified = "XYZ"
        localDataSource.getIndexListLastModifiedExpectation.expectedFulfillmentCount = expectedRequests
        remoteDataSource.getIndexListExpectation.expectedFulfillmentCount = expectedRequests
        localDataSource.putIndexListExpectation.expectedFulfillmentCount = expectedRequests

        // When
        sut.update()

        // Then
        wait(for: [
            localDataSource.getKIDListExpectation,
            localDataSource.getIndexListLastModifiedExpectation,
            remoteDataSource.getIndexListExpectation,
            localDataSource.putIndexListExpectation,
            localDataSource.getChunkListLastModifiedExpectation
        ], timeout: 2)
        XCTAssertEqual(localDataSource.receivedIndexListResponses.count, expectedRequests)
        XCTAssertEqual(remoteDataSource.receivedIndexListHashTypes.count, expectedRequests)
        XCTAssertEqual(Set<CertificateRevocationHashType>(remoteDataSource.receivedIndexListHashTypes).count, 3)
        if let isModified = remoteDataSource.receivedGetIndexListHTTPHeaders[HTTPHeader.ifModifiedSince] {
            XCTAssertEqual(isModified, "XYZ")
        } else {
            XCTFail("HTTP header must be present.")
        }
    }

    func testUpdate_index_lists_local_data_not_modified_no_error() {
        // Given
        remoteDataSource.indexListResponse = nil
        localDataSource.putIndexListExpectation.isInverted = true

        // When
        sut.update()

        // Then
        wait(for: [localDataSource.getChunkListLastModifiedExpectation], timeout: 2)
        XCTAssertTrue(localDataSource.receivedIndexListResponses.isEmpty)
    }

    func testUpdate_index_list_getIndexListError() {
        // Given
        localDataSource.putIndexListExpectation.isInverted = true
        remoteDataSource.getIndexListError = NSError(domain: "TEST", code: 0)

        // When
        sut.update()

        // Then
        wait(for: [localDataSource.putIndexListExpectation], timeout: 2)
        XCTAssertEqual(sut.state, .error)
    }

    func testUpdate_index_list_putIndexListError() {
        // Given
        remoteDataSource.getChunkListExpectation.isInverted = true
        localDataSource.putIndexListError = NSError(domain: "TEST", code: 0)

        // When
        sut.update()

        // Then
        wait(for: [remoteDataSource.getChunkListExpectation], timeout: 2)
        XCTAssertEqual(sut.state, .error)
    }

    func testUpdate_chunk_lists_no_local_data_no_error() {
        // Given
        let expectedRequests = 7
        localDataSource.chunkListLastModified = "XYZ"
        localDataSource.getChunkListLastModifiedExpectation.expectedFulfillmentCount = expectedRequests
        remoteDataSource.getChunkListExpectation.expectedFulfillmentCount = expectedRequests
        localDataSource.putChunkListExpectation.expectedFulfillmentCount = expectedRequests

        // When
        sut.update()

        // Then
        wait(for: [
            localDataSource.getKIDListExpectation,
            localDataSource.getChunkListLastModifiedExpectation,
            remoteDataSource.getChunkListExpectation,
            localDataSource.putChunkListExpectation
        ], timeout: 2)
        XCTAssertEqual(localDataSource.receivedChunkListResponses.count, expectedRequests)
        XCTAssertEqual(localDataSource.receivedChunkListHashTypes.count, expectedRequests)
        XCTAssertEqual(Set<CertificateRevocationHashType>(localDataSource.receivedChunkListHashTypes).count, 3)
        if let isModified = remoteDataSource.receivedGetChunkListHTTPHeaders[HTTPHeader.ifModifiedSince] {
            XCTAssertEqual(isModified, "XYZ")
        } else {
            XCTFail("HTTP header must be present.")
        }
    }

    func testUpdate_chunk_lists_local_data_not_modified_no_error() {
        // Given
        remoteDataSource.chunkListResponse = nil
        localDataSource.putChunkListExpectation.isInverted = true

        // When
        sut.update()

        // Then
        wait(for: [localDataSource.putChunkListExpectation], timeout: 1)
    }

    func testUpdate_chunk_list_getChunkListError() {
        // Given
        localDataSource.putChunkListExpectation.isInverted = true
        remoteDataSource.getIndexListError = NSError(domain: "TEST", code: 0)

        // When
        sut.update()

        // Then
        wait(for: [localDataSource.putChunkListExpectation], timeout: 2)
        XCTAssertEqual(sut.state, .error)
    }

    func testUpdate_chunk_list_putChunkListError() {
        // Given
        persistence.storeExpectation.isInverted = true
        localDataSource.putChunkListError = NSError(domain: "TEST", code: 0)

        // When
        sut.update()

        // Then
        wait(for: [persistence.storeExpectation], timeout: 2)
        XCTAssertEqual(sut.state, .error)
    }
}
