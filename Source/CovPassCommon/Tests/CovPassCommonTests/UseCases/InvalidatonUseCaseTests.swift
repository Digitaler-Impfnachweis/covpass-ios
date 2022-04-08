//
//  InvalidatonUseCaseTest.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import CovPassCommon

class InvalidatonUseCaseTests: XCTestCase {
    
    var sut: InvalidationUseCase!
    var vaccinationRepository: VaccinationRepositoryMock!
    var revocationRepository: CertificateRevocationRepositoryMock!
    var persistence: UserDefaultsPersistence!
    var date: Date!

    override func setUpWithError() throws {
        let token = CBORWebToken.mockVaccinationCertificate.mockVaccinationUVCI("FOO").extended()
        let certList = CertificateList(certificates: [token], favoriteCertificateId: nil)
        persistence = UserDefaultsPersistence()
        date = Date()
        revocationRepository = CertificateRevocationRepositoryMock()
        vaccinationRepository = VaccinationRepositoryMock()
        sut = InvalidationUseCase(certificateList: certList,
                                  revocationRepository: revocationRepository,
                                  vaccinationRepository: vaccinationRepository,
                                  date: date,
                                  userDefaults: persistence)
    }
    
    override func tearDownWithError() throws {
        revocationRepository = nil
        vaccinationRepository = nil
        persistence = nil
        date = nil
        sut = nil
    }
    
    func test_isNotRevoked_ShouldQuery() {
        // GIVEN
        let testExpectation = XCTestExpectation()
        persistence.lastQueriedRevocation = Calendar.current.date(byAdding: .day, value: -2, to: date)
        revocationRepository.isRevoked = false
        // WHEN
        sut.execute().done { token in
            // THEN
            XCTAssertNotNil(token)
            XCTAssertTrue(token.certificates.first!.vaccinationCertificate.isVaccination)
            XCTAssertEqual(token.certificates.first!.vaccinationCertificate.hcert.dgc.uvci, "FOO")
            XCTAssertEqual(token.certificates.first!.isInvalid, false)
            testExpectation.fulfill()
        }
        .catch { error in
            XCTFail("Should not fail")
        }
        wait(for: [revocationRepository.isRevokedExpectation,
                   vaccinationRepository.saveCertExpectation,
                   testExpectation],
             timeout: 0.1,
             enforceOrder: true)
    }
    
    func test_isRevoked_ShouldQuery() {
        // GIVEN
        let testExpectation = XCTestExpectation()
        persistence.lastQueriedRevocation = Calendar.current.date(byAdding: .day, value: -2, to: date)
        revocationRepository.isRevoked = true
        // WHEN
        sut.execute().done { token in
            // THEN
            XCTAssertNotNil(token)
            XCTAssertTrue(token.certificates.first!.vaccinationCertificate.isVaccination)
            XCTAssertEqual(token.certificates.first!.vaccinationCertificate.hcert.dgc.uvci, "FOO")
            XCTAssertEqual(token.certificates.first!.isInvalid, true)
            testExpectation.fulfill()
        }
        .catch { error in
            XCTFail("Should not fail")
        }
        wait(for: [revocationRepository.isRevokedExpectation,
                   vaccinationRepository.saveCertExpectation,
                   testExpectation],
             timeout: 0.1,
             enforceOrder: true)
    }
    
    func test_shouldNotQuery() {
        // GIVEN
        let testExpectation = XCTestExpectation()
        persistence.lastQueriedRevocation = Date()
        // WHEN
        sut.execute().done { token in
            // THEN
            XCTAssertNotNil(token)
            XCTAssertTrue(token.certificates.first!.vaccinationCertificate.isVaccination)
            XCTAssertEqual(token.certificates.first!.vaccinationCertificate.hcert.dgc.uvci, "FOO")
            XCTAssertEqual(token.certificates.first!.isInvalid, false)
            testExpectation.fulfill()
        }
        .catch { error in
            XCTFail("Should not fail")
        }
        wait(for: [testExpectation],
             timeout: 0.1,
             enforceOrder: true)
    }
}
