//
//  QualityAssuranceTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class QualityAssuranceTests: XCTestCase {

    var repository: VaccinationRepository!

    override func setUp() {
        super.setUp()
        repository = VaccinationRepository(
            service: APIServiceMock(),
            keychain: MockPersistence(),
            userDefaults: MockPersistence(),
            publicKeyURL: Bundle.module.url(forResource: "pubkey.pem", withExtension: nil)!,
            initialDataURL: Bundle.commonBundle.url(forResource: "dsc.json", withExtension: nil)!
        )
    }

    override func tearDown() {
        repository = nil
        super.tearDown()
    }

    // Before executing this test you should use the script 'Scripts/copy-eu-certificates.sh' to copy the EU most recent EU certificates
    func testAllEUCertificates() {
        var certificateCount = 0
        var errors = [String]()
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: Bundle.module.bundlePath) else { return XCTFail() }
        for file in files where file.starts(with: "dcc-quality-assurance") {
            certificateCount += 1
            if let data = parseQRCode(file) {
                do {
                    _ = try repository.checkCertificate(data).wait()
                } catch {
                    errors.append("Failed to check certificate \(file) with\(error.displayCodeWithMessage(""))")
                }
            } else {
                XCTFail("Cannot parse QR code from file \(file)")
            }
        }
        errors.forEach { print($0) }
        if !errors.isEmpty {
            XCTFail("\(errors.count) out of \(certificateCount) failed to validate")
        }
    }

    func testSingleEUCertificate() throws {
        let file = "" // e.g. dcc-quality-assurance_DE_1.0.0_VAC.png
        guard let data = parseQRCode(file) else {
            print("Cannot parse QR code from file \(file)")
            return
        }
        _ = try repository.checkCertificate(data).wait()
    }

    // Parse QR Code from given file
    private func parseQRCode(_ filename: String) -> String? {
        guard let file = UIImage(named: filename, in: Bundle.module, compatibleWith: .none),
              let image = CIImage(image: file) else { return nil }
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: image) ?? []
        return (features.first as? CIQRCodeFeature)?.messageString
    }
}
