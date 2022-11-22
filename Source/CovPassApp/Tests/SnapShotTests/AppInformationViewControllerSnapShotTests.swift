//
//  AppInformationViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassUI

class AppInformationViewControllerSnapShotTests: BaseSnapShotTests {
    private var persistence: MockPersistence!
    private var sut: AppInformationViewController!

    override func setUpWithError() throws {
        persistence = .init()
        let viewModel = EnglishAppInformationViewModel(
            router: AppInformationRouterMock(),
            persistence: persistence
        )
        sut = .init(viewModel: viewModel)
    }

    override func tearDown() {
        persistence = nil
        sut = nil
    }

    func testDefault() {
        // Given
        persistence.disableWhatsNew = true
        
        // When
        verifyView(view: sut.view)
    }

    func test_whats_new_enabled() {
        // When
        verifyView(view: sut.view)
    }
}
