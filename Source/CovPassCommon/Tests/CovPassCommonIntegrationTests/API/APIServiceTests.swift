//
//  APIServiceTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Compression
@testable import CovPassCommon
import Foundation
import SwiftCBOR
import XCTest

class APIServiceTests: XCTestCase {
    var sut: APIService!

    override func setUp() {
        super.setUp()
        sut = APIService(
            sessionDelegate: APIServiceDelegate(
                certUrl: Bundle.module.url(forResource: "de.test.dscg.ubirch.com.combined", withExtension: "der")!
            ),
            url: ""
        )
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testTrustListUpdate() {
        do {
            let trustList = try sut.fetchTrustList().wait()

            let seq = trustList.split(separator: "\n")
            if seq.count != 2 {
                XCTFail("failed")
            }

            guard let pubkeyPEM = Bundle.module.url(forResource: "pubkey", withExtension: "pem") else {
                XCTFail()
                return
            }

            // EC public key (prime256v1) sequence headers (26 blocks) needs to be stripped off
            //   so it can be used with SecKeyCreateWithData
            let pubkeyB64 = try String(contentsOf: pubkeyPEM)
                .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
                .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
                .replacingOccurrences(of: "\n", with: "")
            let pubkeyDER = Data(base64Encoded: pubkeyB64)!
            let barekeyDER = pubkeyDER.suffix(from: 26)

            var error: Unmanaged<CFError>?
            guard let publicKey = SecKeyCreateWithData(
                barekeyDER as CFData,
                [
                    kSecAttrKeyType: kSecAttrKeyTypeEC,
                    kSecAttrKeyClass: kSecAttrKeyClassPublic
                ] as CFDictionary,
                &error
            ) else {
                if error != nil {
                    XCTFail(error.debugDescription)
                    return
                }
                XCTFail()
                return
            }

            guard var signature = Data(base64Encoded: String(seq[0])) else {
                XCTFail()
                return
            }
            signature = try ECDSA.convertSignatureData(signature)
            guard let signedData = String(seq[1]).data(using: .utf8)?.sha256() else {
                XCTFail()
                return
            }

            let result = SecKeyVerifySignature(
                publicKey, .ecdsaSignatureDigestX962SHA256,
                signedData as CFData,
                signature as CFData,
                &error
            )
            if error != nil {
                XCTFail(error.debugDescription)
                return
            }

            if result {
                print("VALID")
            } else {
                print("NOT VALID")
            }

        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
