//
//  ReissueResultViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import PromiseKit
import XCTest

class ReissueResultViewModelTests: XCTestCase {
    private var repository: VaccinationRepositoryMock!
    private var promise: Promise<Void>!
    private var resolver: Resolver<Void>!
    private var router: ReissueResultRouterMock!
    private var sut: ReissueResultViewModel!

    override func setUpWithError() throws {
        repository = VaccinationRepositoryMock()
        router = ReissueResultRouterMock()
        let (promise, resolver) = Promise<Void>.pending()
        self.promise = promise
        self.resolver = resolver
        sut = .init(
            router: router,
            vaccinationRepository: repository,
            resolver: resolver,
            newTokens: [CBORWebToken.mockVaccinationCertificate.extended()],
            oldTokens: [
                CBORWebToken.mockVaccinationCertificate.extended(),
                CBORWebToken.mockVaccinationCertificate.extended()
            ]
        )
    }

    override func tearDownWithError() throws {
        repository = nil
        resolver = nil
        router = nil
        sut = nil
    }

    func testDeleteOldTokensLater() {
        // When
        sut.deleteOldTokensLater()

        // Then
        XCTAssertTrue(promise.isFulfilled)
    }


    func testDeleteOldTokens_error() {
        // Given
        repository.deleteError = NSError(domain: "TEST", code: 0, userInfo: nil)
        
        // When
        sut.deleteOldTokens()

        // Then
        wait(for: [router.showErrorExpectation], timeout: 1)
    }
}
