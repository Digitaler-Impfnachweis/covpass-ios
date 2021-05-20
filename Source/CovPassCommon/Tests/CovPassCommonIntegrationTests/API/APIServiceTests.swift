//
//  APIServiceTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Compression
import Foundation
import SwiftCBOR
@testable import CovPassCommon
import XCTest

class APIServiceTests: XCTestCase {
    var sut: APIService!

    override func setUp() {
        super.setUp()
        sut = APIService(
            sessionDelegate: APIServiceDelegate(
                certUrl: Bundle.module.url(forResource: "rsa-certify.demo.ubirch.com", withExtension: "der")!
            ),
            url: ""
        )
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testFetchTrustList() {

        if let filepath = Bundle.commonBundle.path(forResource: "pubkey", ofType: "pem") {
                    do {
                        var contents = try String(contentsOfFile: filepath)
                        print(contents.debugDescription)

                        // remove the header string
                        let offset = String("-----BEGIN PUBLIC KEY-----").count
                        let index = contents.index(contents.startIndex, offsetBy: offset+1)
                        contents = String(contents.suffix(from: index))

                       // remove end of line chars
                       contents = contents.replacingOccurrences(of: "\n", with: "")

                        // remove the tail string
                        let tailWord = "-----END PUBLIC KEY-----"
                        if let lowerBound = contents.range(of: tailWord)?.lowerBound {
                            contents = String(contents.prefix(upTo: lowerBound))
                        }

                        print(contents.debugDescription)

                        let data = NSData(base64Encoded: contents,
                                          options:NSData.Base64DecodingOptions.ignoreUnknownCharacters)!

                        var publicKey: SecKey?
                        let attributes = [kSecAttrKeyType: kSecAttrKeyTypeRSA, kSecAttrKeyClass: kSecAttrKeyClassPublic] as CFDictionary
                        let error = UnsafeMutablePointer<Unmanaged<CFError>?>.allocate(capacity: 1)
                        publicKey = SecKeyCreateWithData(data, attributes, error)

                        print(error.pointee.debugDescription)
                        print(publicKey.debugDescription)

                    } catch {
                        print(error)
                    }
        }

            return
        do {
//            let repo = VaccinationRepository(service: sut, parser: QRCoder())
//            try repo.refreshValidationCA().wait()
            let trustList = try sut.fetchTrustList().wait()

            guard let trustListPublicKey = Bundle.commonBundle.url(forResource: "pubkey", withExtension: "pem") else {
                throw ApplicationError.unknownError
            }
            let trustListPublicKeyData = try Data(contentsOf: trustListPublicKey)

            let attributes: [String:Any] = [
                kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
//                kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
//                kSecAttrKeySizeInBits as String: 2048,
            ]

            var error: Unmanaged<CFError>?
            let publicKey = SecKeyCreateWithData(trustListPublicKeyData as CFData, attributes as CFDictionary, &error)
            if error != nil {
                throw HCertError.verifyError
            }

//            guard let signature = trustList.signature.data(using: .utf8) else {
//                throw ApplicationError.unknownError
//            }

//            XCTAssert(list.certificates.count > 0)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
