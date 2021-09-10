//
//  DataCompressionExtensionTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import Foundation
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

    func testZlibCompressionDecompression() throws {
        guard let compressedData = testString.data(using: .utf8)?.compress(withAlgorithm: .zlib) else {
            XCTFail("Should compress data")
            return
        }
        XCTAssertEqual(compressedData.base64EncodedString(), "JcwxCsMwFAPQqyi7c4EshS5ZM+QCHyJi4/Z/cH5rfPvazSjxpC1pbgtWMuBZJGlAjeI4DM0+qKIOtxHdNJ3RHzdbsEfikjfhMemJyoH4ZWn4w4BtfGOG96p/uGTCOugLolp5HdMP")
        guard let decompressedData = compressedData.decompress(withAlgorithm: .zlib) else {
            XCTFail("Should decompress data")
            return
        }
        XCTAssertEqual(String(data: decompressedData, encoding: .utf8), testString)
    }
}
