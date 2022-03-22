//
//  Data+EncryptionTests.swift
//  
//
//  Created by Thomas Kuleßa on 18.03.22.
//

@testable import CovPassCommon
import Security
import XCTest

class DataEncryptionTests: XCTestCase {
    func testEncrypt() throws {
        // Given
        let algoritm = SecKeyAlgorithm.eciesEncryptionStandardX963SHA256AESGCM
        let sut = try XCTUnwrap("PLAIN TEXT".data(using: .ascii))
        let key = try SecKey.mock()

        XCTAssertNoThrow(
            try sut.encrypt(with: key, algoritm: algoritm)
        )
    }

    func testEncrypt_error() throws {
        // Given
        let algoritm = SecKeyAlgorithm.ecdsaSignatureDigestX962SHA256
        let sut = try XCTUnwrap("PLAIN TEXT".data(using: .ascii))
        let key = try SecKey.mock()

        XCTAssertThrowsError(
            try sut.encrypt(with: key, algoritm: algoritm)
        )
    }
}
