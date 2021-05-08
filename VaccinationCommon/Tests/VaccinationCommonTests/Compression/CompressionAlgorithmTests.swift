//
//  CompressionAlgorithmTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Compression
import Foundation
@testable import VaccinationCommon
import XCTest

class CompressionAlgorithmTests: XCTestCase {
    func testCompressionAlgorithmZlib() throws {
        XCTAssertEqual(CompressionAlgorithm.zlib.lowLevelType, COMPRESSION_ZLIB)
    }

    func testCompressionAlgorithmLzfse() throws {
        XCTAssertEqual(CompressionAlgorithm.lzfse.lowLevelType, COMPRESSION_LZFSE)
    }

    func testCompressionAlgorithmLzma() throws {
        XCTAssertEqual(CompressionAlgorithm.lzma.lowLevelType, COMPRESSION_LZMA)
    }

    func testCompressionAlgorithmLz4() throws {
        XCTAssertEqual(CompressionAlgorithm.lz4.lowLevelType, COMPRESSION_LZ4)
    }
}
