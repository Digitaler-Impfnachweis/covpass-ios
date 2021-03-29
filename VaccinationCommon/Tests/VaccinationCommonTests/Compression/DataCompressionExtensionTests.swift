//
//  DataCompressionExtensionTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import XCTest
@testable import VaccinationCommon

class DataCompressionExtensionTests: XCTestCase {
    
    let testString = "http://daniel.com"
    
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
        guard  let decodedData = decompressedStrData, let strDecompressed = String(data: decodedData, encoding: .utf8) else {
            return XCTFail("Invalid compressed / decompressed data")
        }
        XCTAssertEqual(strDecompressed, testString)
    }
}
