//
//  CertificateRevocationWrapperRepositoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import XCTest

class CertificateRevocationWrapperRepositoryTests: XCTestCase {
    private var localRepository: CertificateRevocationRepositoryMock!
    private var remoteRepository: CertificateRevocationRepositoryMock!
    private var persistence: MockPersistence!
    private var sut: CertificateRevocationWrapperRepository!

    override func setUpWithError() throws {
        localRepository = .init()
        remoteRepository = .init()
        persistence = .init()
        sut = .init(
            localRepository: localRepository,
            remoteRepostory: remoteRepository,
            persistence: persistence
        )
    }

    override func tearDownWithError() throws {
        localRepository = nil
        remoteRepository = nil
        persistence = nil
        sut = nil
    }

    func testIsRevoked_local() {
        // Given
        persistence.isCertificateRevocationOfflineServiceEnabled = true
        remoteRepository.isRevokedExpectation.isInverted = true
        let expectation = XCTestExpectation()

        // When
        sut.isRevoked(CBORWebToken.mockVaccinationCertificate.extended())
            .done { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [
            expectation,
            localRepository.isRevokedExpectation,
            remoteRepository.isRevokedExpectation
        ], timeout: 1)
    }

    func testIsRevoked_remote() {
        // Given
        persistence.isCertificateRevocationOfflineServiceEnabled = false
        localRepository.isRevokedExpectation.isInverted = true
        let expectation = XCTestExpectation()

        // When
        sut.isRevoked(CBORWebToken.mockVaccinationCertificate.extended())
            .done { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [
            expectation,
            localRepository.isRevokedExpectation,
            remoteRepository.isRevokedExpectation
        ], timeout: 1)
    }
}
