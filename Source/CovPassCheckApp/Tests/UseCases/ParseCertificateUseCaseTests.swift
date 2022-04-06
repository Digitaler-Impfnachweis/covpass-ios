//
//  ValidationUseCase.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import CovPassCheckApp
@testable import CovPassCommon
@testable import CovPassUI
import Scanner

class ParseCertificateUseCaseTests: XCTestCase {
    var sut: ParseCertificateUseCase!
    var vaccinationRepository: VaccinationRepositoryMock!
    
    override func setUpWithError() throws {
        let scanResult = ScanResult.success("BAR")
        vaccinationRepository = VaccinationRepositoryMock()
        sut = ParseCertificateUseCase(scanResult: scanResult,
                                      vaccinationRepository: vaccinationRepository)
    }
    
    override func tearDownWithError() throws {
        vaccinationRepository = nil
        sut = nil
    }
    
    func test_ScanResultSuccess_TokenSuccess() {
        // GIVEN
        let testExpectation = XCTestExpectation()
        vaccinationRepository.checkedCert = CBORWebToken.mockVaccinationCertificate.mockVaccinationUVCI("FOO")
        // WHEN
        sut.execute().done { token in
            // THEN
            XCTAssertNotNil(token)
            XCTAssertTrue(token.vaccinationCertificate.isVaccination)
            XCTAssertEqual(token.vaccinationCertificate.hcert.dgc.uvci, "FOO")
            testExpectation.fulfill()
        }
        .catch { error in
            XCTFail("Should not fail")
        }
        wait(for: [testExpectation],
             timeout: 0.1,
             enforceOrder: true)
    }
    
    func test_ScanResultSuccess_TokenError() {
        // GIVEN
        let testExpectation = XCTestExpectation()
        vaccinationRepository.checkedCert = nil
        vaccinationRepository.checkedCertError = Base45CodingError.base45Decoding
        // WHEN
        sut.execute().done { token in
            // THEN
            XCTFail("Should fail")
        }
        .catch { error in
            let certificateError = error as? Base45CodingError
            XCTAssertEqual(certificateError, .base45Decoding)
            testExpectation.fulfill()
        }
        wait(for: [testExpectation],
             timeout: 0.1,
             enforceOrder: true)
    }
    
    func test_ScanResultError() {
        // GIVEN
        let testExpectation = XCTestExpectation()
        sut = ParseCertificateUseCase(scanResult: ScanResult.failure(.badInput),
                                      vaccinationRepository: vaccinationRepository)
        // WHEN
        sut.execute().done { token in
            // THEN
            XCTFail("Should fail")
        }
        .catch { error in
            let certificateError = error as? ScanError
            XCTAssertEqual(certificateError, .badInput)
            testExpectation.fulfill()
        }
        wait(for: [testExpectation],
             timeout: 0.1,
             enforceOrder: true)
    }
}
