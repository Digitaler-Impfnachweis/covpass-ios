//
//  FileManager+PromiseKitTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest

class FileManagerPromiseKitTests: XCTestCase {
    private var sut: FileManagerMock!

    override func setUpWithError() throws {
        sut = .init()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testCreateDirectoryPromise_error() {
        // Given
        let expectedURL = FileManager.default.temporaryDirectory
        let expectation = XCTestExpectation()
        sut.error = NSError(domain: "TEST", code: 0)

        // When
        sut.createDirectoryPromise(
            at: expectedURL,
            withIntermediateDirectories: true,
            attributes: [:]
        )
        .catch { _ in
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testCreateDirectoryPromise_success() {
        // Given
        let expectedURL = FileManager.default.temporaryDirectory
        let expectation = XCTestExpectation()

        // When
        sut.createDirectoryPromise(
            at: expectedURL,
            withIntermediateDirectories: true,
            attributes: [:]
        )
        .done { _ in
            expectation.fulfill()
        }
        .cauterize()

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(sut.createDirectoryCalledWithURL, expectedURL)
    }

    func testCreateFilePromise_error() {
        // Given
        let expectedPath = FileManager.default.temporaryDirectory.path
        let expectedData = Data([1, 2, 4])
        let expectation = XCTestExpectation()
        sut.createFileSuccess = false

        // When
        sut.createFilePromise(atPath: expectedPath, contents: expectedData, attributes: [:])
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testCreateFilePromise_success() {
        // Given
        let expectedPath = FileManager.default.temporaryDirectory.path
        let expectedData = Data([1, 2, 4])
        let expectation = XCTestExpectation()

        // When
        sut.createFilePromise(atPath: expectedPath, contents: expectedData, attributes: [:])
            .done { _ in
                expectation.fulfill()
            }
            .cauterize()

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(sut.createFileCalledWithParameters.count, 1)
        let parameters = sut.createFileCalledWithParameters.first
        XCTAssertEqual(parameters?.path, expectedPath)
        XCTAssertEqual(parameters?.contents, expectedData)
    }
}
