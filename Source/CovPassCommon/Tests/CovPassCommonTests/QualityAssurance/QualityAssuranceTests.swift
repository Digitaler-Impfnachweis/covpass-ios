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
    var certLogic: DCCCertLogic!

    override func setUp() {
        super.setUp()
        repository = VaccinationRepository(
            revocationRepo: CertificateRevocationRepositoryMock(),
            service: APIServiceMock(),
            keychain: MockPersistence(),
            userDefaults: MockPersistence(),
            boosterLogic: BoosterLogicMock(),
            publicKeyURL: Bundle.module.url(forResource: "pubkey.pem", withExtension: nil)!,
            initialDataURL: Bundle.commonBundle.url(forResource: "dsc.json", withExtension: nil)!
        )

        certLogic = DCCCertLogic(
            initialDCCRulesURL: Bundle.commonBundle.url(forResource: "dcc-rules", withExtension: "json")!,
            initialDomesticDCCRulesURL: Bundle.commonBundle.url(forResource: "dcc-domestic-rules", withExtension: "json")!,
            service: DCCServiceMock(),
            keychain: MockPersistence(),
            userDefaults: MockPersistence()
        )
    }

    override func tearDown() {
        repository = nil
        super.tearDown()
    }

    // Before executing this test you should use the script 'Scripts/copy-eu-certificates.sh' to copy the EU most recent EU certificates
    func testAllEUCertificates() throws {
        var certificateCount = 0
        var errors = [String]()
        let files = try XCTUnwrap(FileManager.default.contentsOfDirectory(atPath: Bundle.module.bundlePath))
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

    // Before executing this test you should use the script 'Scripts/copy-eu-certificates.sh' to copy the EU most recent EU certificates
    // Note: This test takes about 5 minutes to complete
    func testAllEUCertificatesWithGermanRules() throws {
        var certificateCount = 0
        var errors = [String]()
        let files = try XCTUnwrap(FileManager.default.contentsOfDirectory(atPath: Bundle.module.bundlePath))
        for file in files where file.starts(with: "dcc-quality-assurance") {
            certificateCount += 1
            if let data = parseQRCode(file) {
                do {
                    let certificate = try repository.checkCertificate(data).wait()
                    do {
                        let result = try certLogic.validate(countryCode: "DE", validationClock: Date(), certificate: certificate)
                        if result.contains(where: { $0.result == .fail || $0.result == .open }) {
                            errors.append("Invalid certificate \(file)  for Germany")
                        }
                    } catch {
                        errors.append("Failed to validate certificate \(file) with\(error.displayCodeWithMessage(""))")
                    }
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
        try XCTSkipIf(file.isEmpty)
        guard let data = parseQRCode(file) else {
            XCTFail("Cannot parse QR code from file \(file)")
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
