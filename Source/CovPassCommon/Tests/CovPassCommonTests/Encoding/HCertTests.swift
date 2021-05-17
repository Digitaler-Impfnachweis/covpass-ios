//
//  HCertTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon

import Compression
import Foundation
import XCTest

class HCertTests: XCTestCase {
    let validCertificate = Bundle.module.url(forResource: "dtrust_demo-bmg_seal_ubirch-02", withExtension: "der")!
    let invalidCertificate = Bundle.module.url(forResource: "rsa-certify.demo.ubirch.com", withExtension: "der")!

    var sut: HCert!
    var base45Encoder: Base45Coder!
    var cose1SignParser: CoseSign1Parser!

    override func setUp() {
        super.setUp()
        sut = HCert()
        base45Encoder = Base45Coder()
        cose1SignParser = CoseSign1Parser()
    }

    override func tearDown() {
        sut = nil
        base45Encoder = nil
        cose1SignParser = nil
        super.tearDown()
    }

    func testVerifiy() {
        let certificate = CertificateMock.validCertificate.stripPrefix()
        let base45Decoded = try! base45Encoder.decode(certificate)
        guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
            XCTFail("Could not decompress QRCode data")
            return
        }
        let cose1SignEncoder = CoseSign1Parser()
        let cosePayload = try! cose1SignEncoder.parse(decompressedPayload)!
        XCTAssertTrue(sut.verify(message: cosePayload, certificates: [validCertificate]))
    }

    func testVerifiyFailsWithInvalidCertificate() {
        let certificate = CertificateMock.validCertificate.stripPrefix()
        let base45Decoded = try! base45Encoder.decode(certificate)
        guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
            XCTFail("Could not decompress QRCode data")
            return
        }
        let cose1SignEncoder = CoseSign1Parser()
        let cosePayload = try! cose1SignEncoder.parse(decompressedPayload)!
        XCTAssertFalse(sut.verify(message: cosePayload, certificates: [invalidCertificate]))
    }

    func testVerifiyFailsWithNoCertificate() {
        let certificate = CertificateMock.validCertificate.stripPrefix()
        let base45Decoded = try! base45Encoder.decode(certificate)
        guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
            XCTFail("Could not decompress QRCode data")
            return
        }
        let cose1SignEncoder = CoseSign1Parser()
        let cosePayload = try! cose1SignEncoder.parse(decompressedPayload)!
        XCTAssertFalse(sut.verify(message: cosePayload, certificates: []))
    }
}
