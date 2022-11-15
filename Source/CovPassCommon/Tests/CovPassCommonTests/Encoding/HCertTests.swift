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
    var trustListValid: TrustList {
        let validCertificate = "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"
        return TrustList(certificates: [TrustCertificate(certificateType: "", country: "", kid: "", rawData: validCertificate, signature: "", thumbprint: "", timestamp: "")])
    }

    var trustListInvalid: TrustList {
        let invalidCertificate = "MIIDujCCAaKgAwIBAgIIKUgZWBL1pnMwDQYJKoZIhvcNAQELBQAwZjELMAkGA1UEBhMCRlIxHTAbBgNVBAoTFElNUFJJTUVSSUUgTkFUSU9OQUxFMR4wHAYDVQQLExVGT1IgVEVTVCBQVVJQT1NFIE9OTFkxGDAWBgNVBAMTD0lOR1JPVVBFIERTYyBDQTAeFw0yMTA2MDIxMjE0MDBaFw0yMTA5MDIxMjE0MDBaMEAxCzAJBgNVBAYTAkZSMREwDwYDVQQKDAhDRVJUSUdOQTEeMBwGA1UEAwwVQ0VSVElHTkEgLSBURVNUIERHQyAxMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAETdygPqv/l6tWFqHFEIEZxfdhtbrBpDgVjmUN4CKOu/EQFwkVVQ/4N0BamwtI0hSnSZP72byk6XqpMErYWRTCbKNdMFswCQYDVR0TBAIwADAdBgNVHQ4EFgQUUjXs7mCY2ZgROQSsw1CN0qM4Zj8wHwYDVR0jBBgwFoAUYLoYTllzE2jOy3VMAuU4OJjOingwDgYDVR0PAQH/BAQDAgeAMA0GCSqGSIb3DQEBCwUAA4ICAQAvxuSBWNOrk+FRIbU42tnwZBllUeNH7cWcrYHV0O+1k3RbpvYa0YE2J0du301/a+0+pqlatR8o8Coe/NFt4/KSu+To+i8uZXiHJn2XrAZgwPqqTvsMUVwFPWhwJpLMCejmU0A8JEhXH7s0BN6orqIH0JKLpl0/MdVviIUksnxPnP2wdCtz6dL5zKhi+Qt8BFr55PL1dvuWxnuFOsKr89MqaexQVe/WvKhG5GXBaJFDbp4USVX9Z8vwp4SfEs5nh0ti0M2fyGrpfPvWWFra/qoRGAUJEPHHPMqZT45c1rXo12+cpme2CYM4rsliQsaqdH462p7YNNI5reBC+WHhzGr9FGq9yZ1gu/yhz1cJxNwE5gsBTWnJmSnRE75lYj1a/GAb+9wfABd1Vx68Fnww3Ngp8lG2T1vEWhwQusj/OmloVbqjJiCi6PcZ1/OSTbx58Zv9ySwDd3QGxPygfMy87FuhT6iWlPv57qTMrgtEjq89J8v3WnReAhp12ru5ehN2Zv0ZkO1Of0H3yxNBsvfHUgpgwsRn4zjLVbkU+a3hr4famOThmB1X0tuikY0mbNtVejPGS0qCgeLgj8ILlUrRtsW4R6WzZdIsz7H9AYnpyZbdMPsa856xBR9s0+AzguJI9kkJxvVcpR//GiXMhs0EdgWj2rouOEPZiFNdWpVRrxv/kw=="
        return TrustList(certificates: [TrustCertificate(certificateType: "", country: "", kid: "", rawData: invalidCertificate, signature: "", thumbprint: "", timestamp: "")])
    }

    func testErrorCode() {
        XCTAssertEqual(HCertError.publicKeyLoadError.errorCode, 411)
        XCTAssertEqual(HCertError.verifyError.errorCode, 412)
        XCTAssertEqual(HCertError.illegalKeyUsage.errorCode, 413)
    }

    func testVerify() {
        let certificate = CertificateMock.validCertificate.stripPrefix()
        let base45Decoded = try! Base45Coder.decode(certificate)
        guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
            XCTFail("Could not decompress QRCode data")
            return
        }
        let cosePayload = try! CoseSign1Message(decompressedPayload: decompressedPayload)
        let trustCert = try? HCert.verify(message: cosePayload, trustList: trustListValid, checkSealCertificate: false)
        XCTAssertNotNil(trustCert)
    }

    func testVerifyFailsWithInvalidCertificate() {
        let certificate = CertificateMock.validCertificate.stripPrefix()
        let base45Decoded = try! Base45Coder.decode(certificate)
        guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
            XCTFail("Could not decompress QRCode data")
            return
        }
        let cosePayload = try! CoseSign1Message(decompressedPayload: decompressedPayload)
        let trustCert = try? HCert.verify(message: cosePayload, trustList: trustListInvalid, checkSealCertificate: false)
        XCTAssertNil(trustCert)
    }

    func testVerifyFailsWithNoCertificate() {
        let certificate = CertificateMock.validCertificate.stripPrefix()
        let base45Decoded = try! Base45Coder.decode(certificate)
        guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
            XCTFail("Could not decompress QRCode data")
            return
        }
        let cosePayload = try! CoseSign1Message(decompressedPayload: decompressedPayload)
        let trustCert = try? HCert.verify(message: cosePayload, trustList: TrustList(certificates: []), checkSealCertificate: false)
        XCTAssertNil(trustCert)
    }

    func testVerifyFailsWithInvalidSignature() {
        let certificate = CertificateMock.invalidCertificateInvalidSignature.stripPrefix()
        let base45Decoded = try! Base45Coder.decode(certificate)
        guard let decompressedPayload = Compression.decompress(Data(base45Decoded)) else {
            XCTFail("Could not decompress QRCode data")
            return
        }
        let cosePayload = try! CoseSign1Message(decompressedPayload: decompressedPayload)
        let trustCert = try? HCert.verify(message: cosePayload, trustList: trustListValid, checkSealCertificate: false)
        XCTAssertNil(trustCert)
    }

    func testMockCertificate() throws {
        let mockCertificate = try CBORWebToken.mockVaccinationCertificate.generateQRCodeData()
        let base45Decoded = try Base45Coder.decode(mockCertificate.stripPrefix())
        guard let decompressedPayload = Data(base45Decoded).decompress(withAlgorithm: .zlib) else {
            XCTFail("Could not decompress QRCode data")
            return
        }
        let cosePayload = try CoseSign1Message(decompressedPayload: Data(decompressedPayload))
        let trustCert = try HCert.verify(message: cosePayload, trustList: TrustList.mock, checkSealCertificate: false)
        XCTAssertNotNil(trustCert)
    }
}
