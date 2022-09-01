//
//  CertificateHolderStatusModelTests.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest

class CertificateHolderStatusModelTests: XCTestCase {
    private var dccCertLogic: DCCCertLogicMock!
    private var vaccinationRepository: VaccinationRepositoryMock!
    private var sut: CertificateHolderStatusModel!

    override func setUpWithError() throws {
        dccCertLogic = .init()
        vaccinationRepository = .init()
        sut = .init(
            dccCertLogic: dccCertLogic,
            vaccinationRepository: vaccinationRepository
        )
    }

    override func tearDownWithError() throws {
        dccCertLogic = nil
        vaccinationRepository = nil
        sut = nil
    }

    func testHolderIsFullyImmunized_vaccinationRepository_has_error() {
        // Given
        let holder = Name(fnt: "ABC")
        let dateOfBirth = Date(timeIntervalSinceReferenceDate: 0)
        vaccinationRepository.error = NSError(domain: "TEST", code: 0)

        // When
        let isFullyImmunized = sut.holderIsFullyImmunized(
            holder,
            dateOfBirth: dateOfBirth
        )

        // Then
        XCTAssertFalse(isFullyImmunized)
    }

    func testHolderIsFullyImmunized_unkown_user() {
        // Given
        let holder = Name(fnt: "ABC")
        let dateOfBirth = Date(timeIntervalSinceReferenceDate: 0)

        // When
        let isFullyImmunized = sut.holderIsFullyImmunized(
            holder,
            dateOfBirth: dateOfBirth
        )

        // Then
        XCTAssertFalse(isFullyImmunized)
    }

    func testHoldeNeedsMask_vaccinationRepository_has_error() {
        // Given
        let holder = Name(fnt: "ABC")
        let dateOfBirth = Date(timeIntervalSinceReferenceDate: 0)
        vaccinationRepository.error = NSError(domain: "TEST", code: 0)

        // When
        let needsMask = sut.holderNeedsMask(
            holder,
            dateOfBirth: dateOfBirth
        )

        // Then
        XCTAssertFalse(needsMask)
    }

    func testHolderNeedsMask_unkown_user() {
        // Given
        let holder = Name(fnt: "ABC")
        let dateOfBirth = Date(timeIntervalSinceReferenceDate: 0)

        // When
        let needsMask = sut.holderNeedsMask(
            holder,
            dateOfBirth: dateOfBirth
        )

        // Then
        XCTAssertFalse(needsMask)
    }
#warning("TODO: Add missing tests.")
}
