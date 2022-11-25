//
//  CertificateRevocationFilesystemDataSourceTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import Foundation
import PromiseKit
import XCTest

class CertificateRevocationFilesystemDataSourceTests: XCTestCase {
    private var fileManager: FileManagerMock!
    private var sut: CertificateRevocationFilesystemDataSource!
    private var baseURL: URL!

    override func setUpWithError() throws {
        fileManager = .init()
        baseURL = fileManager.temporaryDirectory
            .appendingPathComponent("test", isDirectory: true)
        sut = .init(baseURL: baseURL, fileManager: fileManager)
    }

    override func tearDownWithError() throws {
        baseURL = nil
        fileManager = nil
        sut = nil
    }

    func testDeleteAll_success() {
        // Given
        let expectation = XCTestExpectation()
        let baseURL = fileManager.temporaryDirectory
            .appendingPathComponent("test", isDirectory: true)
        // When
        sut.deleteAll()
            .done { _ in
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(fileManager.removeItemCalledWithURL, baseURL)
    }

    func testDeleteAll_failure() {
        // Given
        let expectation = XCTestExpectation()
        fileManager.error = NSError(domain: "TEST", code: 0)

        // When
        sut.deleteAll()
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetKIDListLastModified_not_existing() {
        // Given
        let expectation = XCTestExpectation()

        // When
        sut.getKIDListLastModified()
            .done { lastModified in
                XCTAssertNil(lastModified)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetKIDListLastModified_success() throws {
        // Given
        let expectation = XCTestExpectation()
        let expectedLastModified = "XYZ"
        let expectedPath = baseURL.appendingPathComponent("/kid.lst.last-modified").path
        fileManager.contents = try XCTUnwrap(expectedLastModified.data(using: .utf8))

        // When
        sut.getKIDListLastModified()
            .done { lastModified in
                XCTAssertEqual(lastModified, expectedLastModified)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(fileManager.contentsCalledWithPath, expectedPath)
    }

    func testPutKIDList_error_create_directory() throws {
        // Given
        let expectation = XCTestExpectation()
        fileManager.error = NSError(domain: "TEST", code: 0)
        let response = try XCTUnwrap(
            try CertificateRevocationKIDListResponse(with: .validKidListResponse(), lastModified: "XYZ")
        )

        // When
        sut.putKIDList(response)
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testPutKIDList_error_create_file() throws {
        // Given
        let expectation = XCTestExpectation()
        fileManager.createFileSuccess = false
        let response = try XCTUnwrap(
            try CertificateRevocationKIDListResponse(with: .validKidListResponse(), lastModified: "XYZ")
        )

        // When
        sut.putKIDList(response)
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testPutKIDList_success() throws {
        // Given
        let lastModified = "XYZ"
        let expectedKIDListPath = baseURL.appendingPathComponent("/kid.lst").path
        let expectedLastModifiedListPath = baseURL.appendingPathComponent("/kid.lst.last-modified").path
        let expectedLastModifiedData = try XCTUnwrap(lastModified.data(using: .utf8))
        let expectation = XCTestExpectation()
        let response = try XCTUnwrap(
            try CertificateRevocationKIDListResponse(
                with: .validKidListResponse(),
                lastModified: lastModified
            )
        )
        let expectedKIDListContents = try PropertyListSerialization.data(
            fromPropertyList: response.rawDictionary,
            format: .xml,
            options: 0
        )

        // When
        sut.putKIDList(response)
            .done { _ in
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(fileManager.createDirectoryCalledWithURL, baseURL)
        XCTAssertEqual(fileManager.createFileCalledWithParameters.count, 2)

        let kidListPath = fileManager.createFileCalledWithParameters.first?.path
        let kidListContents = fileManager.createFileCalledWithParameters.first?.contents
        XCTAssertEqual(kidListPath, expectedKIDListPath)
        XCTAssertEqual(kidListContents, expectedKIDListContents)

        let lastModifiedPath = fileManager.createFileCalledWithParameters.last?.path
        let lastModifiedContents = fileManager.createFileCalledWithParameters.last?.contents
        XCTAssertEqual(lastModifiedPath, expectedLastModifiedListPath)
        XCTAssertEqual(lastModifiedContents, expectedLastModifiedData)
    }

    func testGetKIDList_error_file_is_noz_existing() {
        // Given
        let expectation = XCTestExpectation()

        // When
        sut.getKIDList()
            .catch { error in
                let certificateRevocationDataSourceError = error as? CertificateRevocationDataSourceError
                XCTAssertEqual(certificateRevocationDataSourceError, .notFound)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetKIDList_error_file_is_no_dictionary() {
        // Given
        fileManager.contents = Data([1, 2, 3])
        let expectation = XCTestExpectation()

        // When
        sut.getKIDList()
            .catch { error in
                print(error)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetKIDList_error_file_is_wrong_dictionary() throws {
        // Given
        let dictionary: NSDictionary = [
            "date": Date(),
            "number": NSNumber(3.14)
        ]
        fileManager.contents = try PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: 0)
        let expectation = XCTestExpectation()

        // When
        sut.getKIDList()
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetKIDList_success() throws {
        // Given
        let dictionary: NSDictionary = .validKidListResponse()
        fileManager.contents = try PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: 0)
        let expectedKIDListPath = baseURL.appendingPathComponent("/kid.lst").path
        let expectation = XCTestExpectation()

        // When
        sut.getKIDList()
            .done { response in
                XCTAssertEqual(response.rawDictionary, dictionary)
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(fileManager.contentsCalledWithPath, expectedKIDListPath)
    }

    func testGetIndexListLastModified_not_existing() {
        // Given
        let expectation = XCTestExpectation()

        // When
        sut.getIndexListLastModified(kid: [1, 2, 3], hashType: .countryCodeUCI)
            .done { lastModified in
                XCTAssertNil(lastModified)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetIndexKIDListLastModified_signature_success() throws {
        // Given
        let hashType = CertificateRevocationHashType.signature
        let expectedLastModified = "XYZ"
        let kid: KID = [0x01, 0x02, 0x03]
        let expectedPath = baseURL.appendingPathComponent("/0102030a/index.lst.last-modified").path
        let expectation = XCTestExpectation()
        fileManager.contents = try XCTUnwrap(expectedLastModified.data(using: .utf8))

        // When
        sut.getIndexListLastModified(kid: kid, hashType: hashType)
            .done { lastModified in
                XCTAssertEqual(lastModified, expectedLastModified)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(fileManager.contentsCalledWithPath, expectedPath)
    }

    func testGetIndexKIDListLastModified_countryCodeUCI_success() throws {
        // Given
        let hashType = CertificateRevocationHashType.countryCodeUCI
        let expectedLastModified = "XYZ"
        let kid: KID = [0xAB, 0xCD, 0xEF]
        let expectedPath = baseURL.appendingPathComponent("/abcdef0c/index.lst.last-modified").path
        let expectation = XCTestExpectation()
        fileManager.contents = try XCTUnwrap(expectedLastModified.data(using: .utf8))

        // When
        sut.getIndexListLastModified(kid: kid, hashType: hashType)
            .done { lastModified in
                XCTAssertEqual(lastModified, expectedLastModified)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(fileManager.contentsCalledWithPath, expectedPath)
    }

    func testGetIndexKIDListLastModified_uci_success() throws {
        // Given
        let hashType = CertificateRevocationHashType.uci
        let expectedLastModified = "XYZ"
        let kid: KID = [0xAB, 0xCD, 0xEF]
        let expectedPath = baseURL.appendingPathComponent("/abcdef0b/index.lst.last-modified").path
        let expectation = XCTestExpectation()
        fileManager.contents = try XCTUnwrap(expectedLastModified.data(using: .utf8))

        // When
        sut.getIndexListLastModified(kid: kid, hashType: hashType)
            .done { lastModified in
                XCTAssertEqual(lastModified, expectedLastModified)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(fileManager.contentsCalledWithPath, expectedPath)
    }

    func testPutIndexList_error_create_directory() throws {
        // Given
        let expectation = XCTestExpectation()
        fileManager.error = NSError(domain: "TEST", code: 0)
        let response = try XCTUnwrap(
            try CertificateRevocationIndexListByKIDResponse(with: .validIndexListResponse())
        )

        // When
        sut.putIndexList(response, kid: [0x0AA, 0x0BB, 0xCC], hashType: .uci)
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testPutIndexList_error_create_file() throws {
        // Given
        let expectation = XCTestExpectation()
        fileManager.createFileSuccess = false
        let response = try XCTUnwrap(
            try CertificateRevocationIndexListByKIDResponse(with: .validIndexListResponse())
        )

        // When
        sut.putIndexList(response, kid: [0x0AA, 0x0BB, 0xCC], hashType: .uci)
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testPutIndexList_success() throws {
        // Given
        let lastModified = "XYZ"
        let kid: KID = [0xAB, 0xCD, 0xEF]
        let expectedDirectoryPath = baseURL.appendingPathComponent("/abcdef0a")
        let expectedIndexListPath = baseURL.appendingPathComponent("/abcdef0a/index.lst").path
        let expectedLastModifiedListPath = baseURL.appendingPathComponent("/abcdef0a/index.lst.last-modified").path
        let expectedLastModifiedData = try XCTUnwrap(lastModified.data(using: .utf8))
        let expectation = XCTestExpectation()
        let response = try XCTUnwrap(
            try CertificateRevocationIndexListByKIDResponse(
                with: .validIndexListResponse(),
                lastModified: "XYZ"
            )
        )
        let expectedIndexListContents = try PropertyListSerialization.data(
            fromPropertyList: response.rawDictionary,
            format: .xml,
            options: 0
        )

        // When
        sut.putIndexList(response, kid: kid, hashType: .signature)
            .done { _ in
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(fileManager.createDirectoryCalledWithURL, expectedDirectoryPath)
        XCTAssertEqual(fileManager.createFileCalledWithParameters.count, 2)

        let indexListPath = fileManager.createFileCalledWithParameters.first?.path
        let indexListContents = fileManager.createFileCalledWithParameters.first?.contents
        XCTAssertEqual(indexListPath, expectedIndexListPath)
        XCTAssertEqual(indexListContents, expectedIndexListContents)

        let lastModifiedPath = fileManager.createFileCalledWithParameters.last?.path
        let lastModifiedContents = fileManager.createFileCalledWithParameters.last?.contents
        XCTAssertEqual(lastModifiedPath, expectedLastModifiedListPath)
        XCTAssertEqual(lastModifiedContents, expectedLastModifiedData)
    }

    func testGetIndexList_error_file_does_not_exist() {
        // Given
        let kid: KID = [0xAA, 0xBB, 0xCC]
        let hashType = CertificateRevocationHashType.signature
        let expectation = XCTestExpectation()

        // When
        sut.getIndexList(kid: kid, hashType: hashType)
            .catch { error in
                let certificateRevocationDataSourceError = error as? CertificateRevocationDataSourceError
                XCTAssertEqual(certificateRevocationDataSourceError, .notFound)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetIndexList_error_file_is_not_a_dictionary() {
        // Given
        let kid: KID = [0xAA, 0xBB, 0xCC]
        let hashType = CertificateRevocationHashType.signature
        let expectation = XCTestExpectation()
        fileManager.contents = Data([1, 2, 3])

        // When
        sut.getIndexList(kid: kid, hashType: hashType)
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetIndexList_error_file_is_wrong_type_of_dictionary() throws {
        // Given
        let kid: KID = [0xAA, 0xBB, 0xCC]
        let hashType = CertificateRevocationHashType.signature
        let expectation = XCTestExpectation()
        let dictionary: NSDictionary = [
            "date": Date(),
            "number": NSNumber(3.14)
        ]
        fileManager.contents = try PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: 0)

        // When
        sut.getIndexList(kid: kid, hashType: hashType)
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetIndexList_success() throws {
        // Given
        let kid: KID = [0xAA, 0xBB, 0xCC]
        let hashType = CertificateRevocationHashType.signature
        let expectedIndexListPath = baseURL.appendingPathComponent("/aabbcc0a/index.lst").path
        let expectation = XCTestExpectation()
        let dictionary: NSDictionary = .validIndexListResponse()
        fileManager.contents = try PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: 0)

        // When
        sut.getIndexList(kid: kid, hashType: hashType)
            .done { response in
                XCTAssertEqual(response.rawDictionary, dictionary)
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(fileManager.contentsCalledWithPath, expectedIndexListPath)
    }

    func testHeadIndexList_file_exists() {
        // Given
        let kid: KID = [0xAA, 0xBB, 0xCC]
        let hashType = CertificateRevocationHashType.signature
        let expectedIndexListPath = baseURL.appendingPathComponent("/aabbcc0a/index.lst").path
        let expectation = XCTestExpectation()

        // When
        sut.headIndexList(kid: kid, hashType: hashType)
            .done { _ in
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(fileManager.fileExistsCalledWithPath, expectedIndexListPath)
    }

    func testHeadIndexList_file_does_not_exist() {
        // Given
        let kid: KID = [0xAA, 0xBB, 0xCC]
        let hashType = CertificateRevocationHashType.signature
        let expectation = XCTestExpectation()
        fileManager.fileExistsSuccess = false

        // When
        sut.headIndexList(kid: kid, hashType: hashType)
            .catch { error in
                let certificateRevocationDataSourceError = error as? CertificateRevocationDataSourceError
                XCTAssertEqual(certificateRevocationDataSourceError, .notFound)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetChunkListLastModified_not_existing() {
        // Given
        let expectation = XCTestExpectation()

        // When
        sut.getChunkListLastModified(kid: [1, 2, 3], hashType: .countryCodeUCI)
            .done { lastModified in
                XCTAssertNil(lastModified)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetChunkListLastModified_signature_success() throws {
        // Given
        let hashType = CertificateRevocationHashType.signature
        let expectedLastModified = "XYZ"
        let kid: KID = [0x01, 0x02, 0x03]
        let expectedPath = baseURL.appendingPathComponent("/0102030a/chunk.lst.last-modified").path
        let expectation = XCTestExpectation()
        fileManager.contents = try XCTUnwrap(expectedLastModified.data(using: .utf8))

        // When
        sut.getChunkListLastModified(kid: kid, hashType: hashType)
            .done { lastModified in
                XCTAssertEqual(lastModified, expectedLastModified)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(fileManager.contentsCalledWithPath, expectedPath)
    }

    func testGetChunkListLastModified_countryCodeUCI_success() throws {
        // Given
        let hashType = CertificateRevocationHashType.countryCodeUCI
        let expectedLastModified = "XYZ"
        let kid: KID = [0xAB, 0xCD, 0xEF]
        let expectedPath = baseURL.appendingPathComponent("/abcdef0c/chunk.lst.last-modified").path
        let expectation = XCTestExpectation()
        fileManager.contents = try XCTUnwrap(expectedLastModified.data(using: .utf8))

        // When
        sut.getChunkListLastModified(kid: kid, hashType: hashType)
            .done { lastModified in
                XCTAssertEqual(lastModified, expectedLastModified)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(fileManager.contentsCalledWithPath, expectedPath)
    }

    func testGetChunkListLastModified_uci_success() throws {
        // Given
        let hashType = CertificateRevocationHashType.uci
        let expectedLastModified = "XYZ"
        let kid: KID = [0xAB, 0xCD, 0xEF]
        let expectedPath = baseURL.appendingPathComponent("/abcdef0b/chunk.lst.last-modified").path
        let expectation = XCTestExpectation()
        fileManager.contents = try XCTUnwrap(expectedLastModified.data(using: .utf8))

        // When
        sut.getChunkListLastModified(kid: kid, hashType: hashType)
            .done { lastModified in
                XCTAssertEqual(lastModified, expectedLastModified)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(fileManager.contentsCalledWithPath, expectedPath)
    }

    func testPutChunkList_error_create_directory() throws {
        // Given
        let expectation = XCTestExpectation()
        fileManager.error = NSError(domain: "TEST", code: 0)
        let response = try XCTUnwrap(
            CertificateRevocationChunkListResponse(hashes: [])
        )

        // When
        sut.putChunkList(response, kid: [0x0AA, 0x0BB, 0xCC], hashType: .uci)
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testPutChunkList_error_create_file() throws {
        // Given
        let expectation = XCTestExpectation()
        fileManager.createFileSuccess = false
        let response = try XCTUnwrap(
            CertificateRevocationChunkListResponse(hashes: [])
        )

        // When
        sut.putChunkList(response, kid: [0x0AA, 0x0BB, 0xCC], hashType: .uci)
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testPutChunkList_success() throws {
        // Given
        let lastModified = "XYZ"
        let kid: KID = [0xAB, 0xCD, 0xEF]
        let expectedDirectoryPath = baseURL.appendingPathComponent("/abcdef0a")
        let expectedChunkListPath = baseURL.appendingPathComponent("/abcdef0a/chunk.lst").path
        let expectedLastModifiedListPath = baseURL.appendingPathComponent("/abcdef0a/chunk.lst.last-modified").path
        let expectedLastModifiedData = try XCTUnwrap(lastModified.data(using: .utf8))
        let expectation = XCTestExpectation()
        let response = CertificateRevocationChunkListResponse(
            hashes: [
                [0xAA, 0xAA, 0xAA],
                [0xBB, 0xBB, 0xBB],
                [0xCC, 0xCC, 0xCC]
            ],
            lastModified: lastModified
        )
        let expectedChunkListContents = try JSONSerialization.data(withJSONObject: response.hashes, options: [])

        // When
        sut.putChunkList(response, kid: kid, hashType: .signature)
            .done { _ in
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(fileManager.createDirectoryCalledWithURL, expectedDirectoryPath)
        XCTAssertEqual(fileManager.createFileCalledWithParameters.count, 2)

        let indexListPath = fileManager.createFileCalledWithParameters.first?.path
        let indexListContents = fileManager.createFileCalledWithParameters.first?.contents
        XCTAssertEqual(indexListPath, expectedChunkListPath)
        XCTAssertEqual(indexListContents, expectedChunkListContents)

        let lastModifiedPath = fileManager.createFileCalledWithParameters.last?.path
        let lastModifiedContents = fileManager.createFileCalledWithParameters.last?.contents
        XCTAssertEqual(lastModifiedPath, expectedLastModifiedListPath)
        XCTAssertEqual(lastModifiedContents, expectedLastModifiedData)
    }

    func testGetChunkList_error_file_does_not_exist() {
        // Given
        let kid: KID = [0xAA, 0xBB, 0xCC]
        let hashType = CertificateRevocationHashType.signature
        let expectation = XCTestExpectation()

        // When
        sut.getChunkList(kid: kid, hashType: hashType)
            .catch { error in
                let certificateRevocationDataSourceError = error as? CertificateRevocationDataSourceError
                XCTAssertEqual(certificateRevocationDataSourceError, .notFound)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetChunkList_error_file_is_not_a_dictionary() {
        // Given
        let kid: KID = [0xAA, 0xBB, 0xCC]
        let hashType = CertificateRevocationHashType.signature
        let expectation = XCTestExpectation()
        fileManager.contents = Data([1, 2, 3])

        // When
        sut.getChunkList(kid: kid, hashType: hashType)
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetChunkList_error_file_is_wrong_type_of_dictionary() throws {
        // Given
        let kid: KID = [0xAA, 0xBB, 0xCC]
        let hashType = CertificateRevocationHashType.signature
        let expectation = XCTestExpectation()
        let dictionary: NSDictionary = [
            "date": Date(),
            "number": NSNumber(3.14)
        ]
        fileManager.contents = try PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: 0)

        // When
        sut.getChunkList(kid: kid, hashType: hashType)
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetChunkList_success() throws {
        // Given
        let kid: KID = [0xAA, 0xBB, 0xCC]
        let hashType = CertificateRevocationHashType.signature
        let expectedChunkListPath = baseURL.appendingPathComponent("/aabbcc0a/chunk.lst").path
        let expectation = XCTestExpectation()
        let expectedHashes: [CertificateRevocationHash] = [
            [0xAA, 0xAA, 0xAA],
            [0xBB, 0xBB, 0xBB],
            [0xCC, 0xCC, 0xCC]
        ]
        let response = CertificateRevocationChunkListResponse(hashes: expectedHashes)
        fileManager.contents = try JSONSerialization.data(withJSONObject: response.hashes, options: [])

        // When
        sut.getChunkList(kid: kid, hashType: hashType)
            .done { response in
                XCTAssertEqual(response.hashes, expectedHashes)
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(fileManager.contentsCalledWithPath, expectedChunkListPath)
    }

    func testHeadChunkIndexList_file_exists() {
        // Given
        let kid: KID = [0xAA, 0xBB, 0xCC]
        let hashType = CertificateRevocationHashType.signature
        let expectedChunkListPath = baseURL.appendingPathComponent("/aabbcc0a/chunk.lst").path
        let expectation = XCTestExpectation()

        // When
        sut.headChunkList(kid: kid, hashType: hashType)
            .done { _ in
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(fileManager.fileExistsCalledWithPath, expectedChunkListPath)
    }

    func testHeadChunkList_file_does_not_exist() {
        // Given
        let kid: KID = [0xAA, 0xBB, 0xCC]
        let hashType = CertificateRevocationHashType.signature
        let expectation = XCTestExpectation()
        fileManager.fileExistsSuccess = false

        // When
        sut.headChunkList(kid: kid, hashType: hashType)
            .catch { error in
                let certificateRevocationDataSourceError = error as? CertificateRevocationDataSourceError
                XCTAssertEqual(certificateRevocationDataSourceError, .notFound)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetChunkListByte1Byte2_error_request() {
        // Given
        let kid: KID = [0xFF, 0xFF, 0xFF, 0xFF]
        let hashType = CertificateRevocationHashType.uci
        let expectation = XCTestExpectation()

        // When
        sut.getChunkList(kid: kid, hashType: hashType, byte1: 0x01, byte2: 0x23)
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetChunkListByte1Byte2_error_byte1_wrong() throws {
        // Given
        let kid: KID = [0xFF, 0xFF, 0xFF, 0xFF]
        let hashType = CertificateRevocationHashType.uci
        let expectation = XCTestExpectation()
        let hashes: [CertificateRevocationHash] = [
            [0xAA, 0xAA, 0xAA],
            [0xBB, 0xBB, 0xBB],
            [0xCC, 0xCC, 0xCC]
        ]
        fileManager.contents = try JSONSerialization.data(withJSONObject: hashes, options: [])

        // When
        sut.getChunkList(kid: kid, hashType: hashType, byte1: 0x01, byte2: nil)
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetChunkListByte1Byte2_error_byte2_wrong() throws {
        // Given
        let kid: KID = [0xFF, 0xFF, 0xFF, 0xFF]
        let hashType = CertificateRevocationHashType.uci
        let expectation = XCTestExpectation()
        let hashes: [CertificateRevocationHash] = [
            [0xAA, 0xAA, 0xAA],
            [0xBB, 0xBB, 0xBB],
            [0xCC, 0xCC, 0xCC]
        ]
        fileManager.contents = try JSONSerialization.data(withJSONObject: hashes, options: [])

        // When
        sut.getChunkList(kid: kid, hashType: hashType, byte1: 0xBB, byte2: 0xCC)
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetChunkListByte1Byte2_success_byte1_correct() throws {
        // Given
        let kid: KID = [0xFF, 0xFF, 0xFF, 0xFF]
        let hashType = CertificateRevocationHashType.uci
        let expectation = XCTestExpectation()
        let hash1: CertificateRevocationHash = [0xBB, 0xBB, 0xBB]
        let hash2: CertificateRevocationHash = [0xBB, 0xBB, 0xAB]
        let hashes: [CertificateRevocationHash] = [
            [0xAA, 0xAA, 0xAA],
            hash1,
            hash2,
            [0xCC, 0xCC, 0xCC]
        ]
        fileManager.contents = try JSONSerialization.data(withJSONObject: hashes, options: [])

        // When
        sut.getChunkList(kid: kid, hashType: hashType, byte1: 0xBB, byte2: nil)
            .done { response in
                XCTAssertEqual(response.hashes.count, 2)
                XCTAssertTrue(response.hashes.contains(hash1))
                XCTAssertTrue(response.hashes.contains(hash2))
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testGetChunkListByte1Byte2_success_byte1_and_2_correct() throws {
        // Given
        let kid: KID = [0xFF, 0xFF, 0xFF, 0xFF]
        let hashType = CertificateRevocationHashType.uci
        let expectation = XCTestExpectation()
        let hash1: CertificateRevocationHash = [0xBB, 0xBB, 0xBB]
        let hash2: CertificateRevocationHash = [0xBB, 0xBB, 0xAB]
        let hashes: [CertificateRevocationHash] = [
            [0xAA, 0xAA, 0xAA],
            hash1,
            hash2,
            [0xBB, 0xAB, 0xBB],
            [0xCC, 0xCC, 0xCC]
        ]
        fileManager.contents = try JSONSerialization.data(withJSONObject: hashes, options: [])

        // When
        sut.getChunkList(kid: kid, hashType: hashType, byte1: 0xBB, byte2: 0xBB)
            .done { response in
                XCTAssertEqual(response.hashes.count, 2)
                XCTAssertTrue(response.hashes.contains(hash1))
                XCTAssertTrue(response.hashes.contains(hash2))
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testHeadChunkListByte1Byte2_byte_1_does_not_exist() throws {
        // Given
        let kid: KID = [0xFF, 0xFF, 0xFF, 0xFF]
        let hashType = CertificateRevocationHashType.uci
        let expectation = XCTestExpectation()
        let hashes: [CertificateRevocationHash] = [
            [0xAA, 0xAA, 0xAA],
            [0xBB, 0xAB, 0xBB],
            [0xCC, 0xCC, 0xCC]
        ]
        fileManager.contents = try JSONSerialization.data(withJSONObject: hashes, options: [])

        // When
        sut.headChunkList(kid: kid, hashType: hashType, byte1: 0xFE, byte2: nil)
            .catch { error in
                let certificateRevocationDataSourceError = error as? CertificateRevocationDataSourceError
                XCTAssertEqual(certificateRevocationDataSourceError, .notFound)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testHeadChunkListByte1Byte2_byte_2_does_not_exist() throws {
        // Given
        let kid: KID = [0xFF, 0xFF, 0xFF, 0xFF]
        let hashType = CertificateRevocationHashType.uci
        let expectation = XCTestExpectation()
        let hashes: [CertificateRevocationHash] = [
            [0xAA, 0xAA, 0xAA],
            [0xBB, 0xAB, 0xBB],
            [0xCC, 0xCC, 0xCC]
        ]
        fileManager.contents = try JSONSerialization.data(withJSONObject: hashes, options: [])

        // When
        sut.headChunkList(kid: kid, hashType: hashType, byte1: 0xBB, byte2: 0xDE)
            .catch { error in
                let certificateRevocationDataSourceError = error as? CertificateRevocationDataSourceError
                XCTAssertEqual(certificateRevocationDataSourceError, .notFound)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testHeadChunkListByte1Byte2_byte_1_exists() throws {
        // Given
        let kid: KID = [0xFF, 0xFF, 0xFF, 0xFF]
        let hashType = CertificateRevocationHashType.uci
        let expectation = XCTestExpectation()
        let hashes: [CertificateRevocationHash] = [
            [0xAA, 0xAA, 0xAA],
            [0xBB, 0xAB, 0xBB],
            [0xCC, 0xCC, 0xCC]
        ]
        fileManager.contents = try JSONSerialization.data(withJSONObject: hashes, options: [])

        // When
        sut.headChunkList(kid: kid, hashType: hashType, byte1: 0xCC, byte2: nil)
            .done { _ in
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testHeadChunkListByte1Byte2_byte_1_and_2_exists() throws {
        // Given
        let kid: KID = [0xFF, 0xFF, 0xFF, 0xFF]
        let hashType = CertificateRevocationHashType.uci
        let expectation = XCTestExpectation()
        let hashes: [CertificateRevocationHash] = [
            [0xAA, 0xAA, 0xAA],
            [0xBB, 0xAB, 0xBB],
            [0xCC, 0xCC, 0xCC]
        ]
        fileManager.contents = try JSONSerialization.data(withJSONObject: hashes, options: [])

        // When
        sut.headChunkList(kid: kid, hashType: hashType, byte1: 0xCC, byte2: 0xCC)
            .done { _ in
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 1)
    }
}
