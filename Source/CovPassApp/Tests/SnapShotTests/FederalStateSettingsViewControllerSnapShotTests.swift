//
//  StateSelectionSettingsViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassUI

class FederalStateSettingsViewControllerSnapShotTests: BaseSnapShotTests {
    private var persistence: MockPersistence!
    private var sut: FederalStateSettingsViewController!

    override func setUp() {
        super.setUp()
        persistence = .init()
        let viewModel = FederalStateSettingsViewModel(
            router: FederalStateSettingsRouterMock(),
            userDefaults: persistence
        )
        sut = .init(viewModel: viewModel)
    }

    override func tearDown() {
        persistence = nil
        sut = nil
        super.tearDown()
    }

    func testDefault() {
        // Given
        persistence.disableWhatsNew = true

        // When
        verifyView(vc: sut)
    }
}
