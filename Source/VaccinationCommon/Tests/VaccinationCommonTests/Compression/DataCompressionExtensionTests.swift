//
//  DataCompressionExtensionTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import VaccinationCommon
import XCTest

class DataCompressionExtensionTests: XCTestCase {
    let testString = "Pinky: Gee, Brain, what do you want to do tonight? Brain: The same thing we do every night, Pinky - try to take over the world!"

    // MARK: - Tests

    func testCompressionAlgorithmZlib() throws {
        callCompresssionAlgorithm(algorithm: .zlib)
    }

    func testCompressionAlgorithmLzfse() throws {
        callCompresssionAlgorithm(algorithm: .lzfse)
    }

    func testCompressionAlgorithmLzma() throws {
        callCompresssionAlgorithm(algorithm: .lzma)
    }

    func testCompressionAlgorithmLz4() throws {
        callCompresssionAlgorithm(algorithm: .lz4)
    }

    func callCompresssionAlgorithm(algorithm: CompressionAlgorithm) {
        let someStrData = testString.data(using: .utf8)
        let compressdStrData = someStrData?.compress(withAlgorithm: algorithm)
        let decompressedStrData = compressdStrData?.decompress(withAlgorithm: algorithm)
        guard let decodedData = decompressedStrData, let strDecompressed = String(data: decodedData, encoding: .utf8) else {
            return XCTFail("Invalid compressed / decompressed data")
        }
        XCTAssertEqual(strDecompressed, testString)
    }
}
