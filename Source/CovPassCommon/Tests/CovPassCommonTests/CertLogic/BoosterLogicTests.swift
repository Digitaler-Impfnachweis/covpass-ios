//
//  BoosterLogicTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
@testable import CovPassCommon
import Foundation
import PromiseKit
import SwiftyJSON
import XCTest

class BoosterLogicTests: XCTestCase {
    var userDefaults: MockPersistence!
    var certLogic: DCCCertLogicMock!
    var sut: BoosterLogic!
    var repository: VaccinationRepositoryProtocol!

    override func setUp() {
        super.setUp()
        userDefaults = MockPersistence()
        certLogic = DCCCertLogicMock()
        sut = BoosterLogic(certLogic: certLogic, userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults = nil
        certLogic = nil
        sut = nil
        super.tearDown()
    }

    func testBoosterCandidate() {
        let cert = CBORWebToken.mockVaccinationCertificate.extended()
        let sut = BoosterCandidate(certificate: cert)
        XCTAssertEqual(sut.name, cert.vaccinationCertificate.hcert.dgc.nam.fullName)
        XCTAssertEqual(sut.birthdate, cert.vaccinationCertificate.hcert.dgc.dobString)
        XCTAssertEqual(sut.vaccinationIdentifier, cert.vaccinationCertificate.hcert.dgc.uvci)
        XCTAssertEqual(sut.state, .none)
        XCTAssertEqual(sut.validationRules, [])
    }

    func testBoosterCandidateEquatable() {
        XCTAssertEqual(
            BoosterCandidate(name: "foo", birthdate: "bar", vaccinationIdentifier: "", state: .none, validationRules: []),
            BoosterCandidate(name: "foo", birthdate: "bar", vaccinationIdentifier: "", state: .none, validationRules: [])
        )
        XCTAssertNotEqual(
            BoosterCandidate(name: "foo", birthdate: "bar", vaccinationIdentifier: "", state: .none, validationRules: []),
            BoosterCandidate(name: "foo1", birthdate: "bar", vaccinationIdentifier: "", state: .none, validationRules: [])
        )
        XCTAssertNotEqual(
            BoosterCandidate(name: "foo", birthdate: "bar", vaccinationIdentifier: "", state: .none, validationRules: []),
            BoosterCandidate(name: "foo", birthdate: "bar1", vaccinationIdentifier: "", state: .none, validationRules: [])
        )
    }

    func testCheckForNewBoosterVaccinationsIfNeeded() throws {
        XCTAssertNil(try userDefaults.fetch(UserDefaults.keyLastCheckedBooster) as? Date)

        _ = try sut.checkForNewBoosterVaccinationsIfNeeded([]).wait()
        XCTAssertNotNil(try userDefaults.fetch(UserDefaults.keyLastCheckedBooster) as? Date)

        do {
            // Second call should fail because it should check only once a day
            _ = try sut.checkForNewBoosterVaccinationsIfNeeded([]).wait()
        } catch {
            XCTAssertNotNil(error as? CovPassCommon.PromiseCancelledError)
        }
    }

    func testCheckBoosterVaccinations() throws {
        let cert = CBORWebToken.mockVaccinationCertificate.extended()
        let certificatePair = CertificatePair(certificates: [cert])
        XCTAssertFalse(try sut.checkForNewBoosterVaccinations([certificatePair]).wait())
        XCTAssertEqual(sut.checkCertificates([cert])?.state, BoosterCandidate.BoosterState.none)

        // Check same certificate with failed validation result
        certLogic.validateResult = [ValidationResult(rule: Rule.mock, result: .fail, validationErrors: [])]
        XCTAssertFalse(try sut.checkForNewBoosterVaccinations([certificatePair]).wait())
        XCTAssertEqual(sut.checkCertificates([cert])?.state, BoosterCandidate.BoosterState.none)

        // Check same certificate with positive validation result
        certLogic.validateResult = [ValidationResult(rule: Rule.mock, result: .passed, validationErrors: [])]
        XCTAssert(try sut.checkForNewBoosterVaccinations([certificatePair]).wait())
        XCTAssertEqual(sut.checkCertificates([cert])?.state, BoosterCandidate.BoosterState.new)

        // Edge case, user has booster notification but rules changed so that the notification will be removed again
        certLogic.validateResult = [ValidationResult(rule: Rule.mock, result: .fail, validationErrors: [])]
        XCTAssertFalse(try sut.checkForNewBoosterVaccinations([certificatePair]).wait())
        XCTAssertEqual(sut.checkCertificates([cert])?.state, BoosterCandidate.BoosterState.none)
    }

    func testCheckBoosterVaccinationFails() {
        let cert = CBORWebToken.mockVaccinationCertificate.extended()
        let certificatePair = CertificatePair(certificates: [cert])
        do {
            certLogic.validationError = ApplicationError.unknownError
            _ = try sut.checkForNewBoosterVaccinations([certificatePair]).wait()
        } catch {
            XCTAssertEqual(error.localizedDescription, ApplicationError.unknownError.localizedDescription)
        }
    }

    func testCheckBoosterCandidate() {
        XCTAssertNil(sut.checkCertificates([]))

        // Returns default booster candidate that is not persisted
        let cert = CBORWebToken.mockVaccinationCertificate.extended()
        XCTAssertNotNil(sut.checkCertificates([cert]))
        XCTAssertEqual(userDefaultBoosterCandidates.count, 0)

        // Persists booster candidate
        sut.updateBoosterCandidate(BoosterCandidate(certificate: cert))
        XCTAssertNotNil(sut.checkCertificates([cert]))
        XCTAssertEqual(userDefaultBoosterCandidates.count, 1)
        XCTAssertEqual(sut.checkCertificates([cert])?.state, BoosterCandidate.BoosterState.none)

        // Update status of persisted booster candidate
        var candidate = BoosterCandidate(certificate: cert)
        candidate.state = .new
        sut.updateBoosterCandidate(candidate)
        XCTAssertEqual(userDefaultBoosterCandidates.count, 1)
        XCTAssertEqual(sut.checkCertificates([cert])?.state, BoosterCandidate.BoosterState.new)

        // Delete different certificate that does not match booster candidate
        let differentCert = CBORWebToken.mockVaccinationCertificate.mockVaccinationUVCI("foo").extended()
        sut.deleteBoosterCandidate(forCertificate: differentCert)
        XCTAssertEqual(userDefaultBoosterCandidates.count, 1)

        // Delete booster candidate for certificate
        sut.deleteBoosterCandidate(forCertificate: cert)
        XCTAssertEqual(userDefaultBoosterCandidates.count, 0)
    }

    // MARK: - Helpers

    private var userDefaultBoosterCandidates: [BoosterCandidate] {
        guard let data = try? userDefaults.fetch(UserDefaults.keyBoosterCandidates) as? Data,
              let boosterCandidates = try? JSONDecoder().decode([BoosterCandidate].self, from: data)
        else { return [] }
        return boosterCandidates
    }
}
