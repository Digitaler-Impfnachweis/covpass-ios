//
//  SVGPDFExporterTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class SVGPDFExporterTests: XCTestCase {
    var sut: SVGPDFExporter!

    override func setUpWithError() throws {
        sut = SVGPDFExporter(converter: SVGToPDFConverter())
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testVaccinationPDFExport() throws {
        let template = try XCTUnwrap(Template(string: "", type: .vaccination))
        let cert = CBORWebToken.mockVaccinationCertificate.extended()

        let svg = try XCTUnwrap(try sut.fill(template: template, with: cert))
        let exp = expectation(description: "exp")
        sut.export(svg, completion: { res in
            XCTAssertNotNil(res)
            exp.fulfill()
        })
        wait(for: [exp], timeout: 10.0)
    }

    func testRecoveryPDFExport() throws {
        let template = try XCTUnwrap(Template(string: "", type: .recovery))
        let cert = CBORWebToken.mockRecoveryCertificate.extended()

        let svg = try XCTUnwrap(try sut.fill(template: template, with: cert))
        let exp = expectation(description: "exp")
        sut.export(svg, completion: { res in
            XCTAssertNotNil(res)
            exp.fulfill()
        })
        wait(for: [exp], timeout: 10.0)
    }

    func testTemplate() {
        XCTAssertEqual(try XCTUnwrap(CBORWebToken.mockVaccinationCertificate.hcert.dgc.template).type, .vaccination)
        XCTAssertEqual(try XCTUnwrap(CBORWebToken.mockVaccinationCertificate.hcert.dgc.template).data.count, 28721)
        XCTAssertEqual(try XCTUnwrap(CBORWebToken.mockRecoveryCertificate.hcert.dgc.template).type, .recovery)
        XCTAssertEqual(try XCTUnwrap(CBORWebToken.mockRecoveryCertificate.hcert.dgc.template).data.count, 184_129)
        XCTAssertEqual(try XCTUnwrap(CBORWebToken.mockTestCertificate.hcert.dgc.template).type, .test)
        XCTAssertEqual(try XCTUnwrap(CBORWebToken.mockTestCertificate.hcert.dgc.template).data.count, 94012)

        // Export of certificates from other countries should fail
        let cert = CBORWebToken.mockVaccinationCertificate
        cert.hcert.dgc.v?[0].co = "ES"
        XCTAssertNil(cert.hcert.dgc.template)
    }
}
