//
//  File.swift
//  
//
//  Created by Thomas Kuleßa on 24.03.22.
//

@testable import CovPassCommon
import XCTest

class SecKeyCoseSign1MessageTests: XCTestCase {
    private var sut: SecKey!

    override func setUpWithError() throws {
        sut = try matchingPublicKey.secKey()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testVerify_error() throws {
        // Given
        let message = CoseSign1Message(
            protected: [],
            unprotected: nil,
            payload: [],
            signature: [1, 2, 3]
        )


        // When & Then
        XCTAssertThrowsError(try sut.verify(message))
    }

    func testVerify_does_not_verify() throws {
        // Given
        let data = try XCTUnwrap(Data(base64Encoded: messageSignedWithOtherKey))
        let message = try CoseSign1Message(decompressedPayload: data)

        // When & Then
        XCTAssertThrowsError(try sut.verify(message))
    }

    func testVerify_success() throws {
        // Given
        let data = try XCTUnwrap(Data(base64Encoded: message))
        let message = try CoseSign1Message(decompressedPayload: data)

        // When
        let verified = try sut.verify(message)

        // Then
        XCTAssertTrue(verified)
    }
}

private let matchingPublicKey = """
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE6Ft4aTjScTpsvY0tg2Lx0AK0Ih3Z
2VKXnyBvoZxngB9cXmNtTg+Va3fY3QJduf+OXaWsE34xvMTIHxw+MpOLkw==
-----END PUBLIC KEY-----
"""

private let message = "0oRDoQEmoFhcpklptx1ptx1ptx2hQQoBSGFiY2RlZmdooUEKA0j1xZcMMDnYVKNBCgRBCwFBDAFIjErg7UWLZ/GhQQoCSAeAWyUMdZWEo0EKAkELAkEMAkj1AVmjLYTonaFBCwVYQPvCkhxAu2OpXTWXK5Fwcp5ghZWoquDDxu8ROlouygn6psPRt/AXVD0EBXBCNwqI6mp4ZKzUc2qdygskw9fuwwk="

private let messageSignedWithOtherKey = "0oRDoQEmoQRQjt4zFtTaQYGB8HU6/8ajo1kBHKQBYkRFBBpidoyjBhpglVkjOQEDoQGkYXaBqmJjaXgxMDFERS8wMDEwMC8xMTE5MzQ5MDA3L0Y0RzcwMTRLUVEyWEQwTlk4RkpIU1REWFojU2Jjb2JERWJkbgJiZHRqMjAyMS0wMi0yOGJpc3gqQnVuZGVzbWluaXN0ZXJpdW0gZsO8ciBHZXN1bmRoZWl0IChUZXN0MDEpYm1hbU9SRy0xMDAwMzAyMTVibXBsRVUvMS8yMC8xNTI4YnNkAmJ0Z2k4NDA1MzkwMDZidnBqMTExOTM0OTAwN2Nkb2JqMTk5Ny0wMS0wNmNuYW2kYmZuZUlvbnV0YmduZUJhbGFpY2ZudGVJT05VVGNnbnRlQkFMQUljdmVyZTEuMC4wWEC9eoLxc6ULO8vhrnBQOPL+/aSF3+8xgoDLe1eO3+KcfWFuHEw/nDp8bSJju6yAjah5f3TRH5fq6kyR+9ts/3yY"

/*
 let base64EncodedCoseMessage = "0oRDoQEmoFhcpklptx1ptx1ptx2hQQoBSGFiY2RlZmdooUEKA0j1xZcMMDnYVKNBCgRBCwFBDAFIjErg7UWLZ/GhQQoCSAeAWyUMdZWEo0EKAkELAkEMAkj1AVmjLYTonaFBCwVYQPvCkhxAu2OpXTWXK5Fwcp5ghZWoquDDxu8ROlouygn6psPRt/AXVD0EBXBCNwqI6mp4ZKzUc2qdygskw9fuwwk="
 */
