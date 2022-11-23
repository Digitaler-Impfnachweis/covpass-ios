//
//  StateSelectionSettingsViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
@testable import CovPassApp
@testable import CovPassUI

class FederalStateSettingsViewControllerSnapShotTests: BaseSnapShotTests {
    private var persistence: MockPersistence!
    private var certificateHolderStatus: CertificateHolderStatusModelMock!
    private var sut: FederalStateSettingsViewController!

    override func setUp() {
        super.setUp()
        persistence = .init()
        certificateHolderStatus = CertificateHolderStatusModelMock()
        let viewModel = FederalStateSettingsViewModel(
            router: FederalStateSettingsRouterMock(),
            userDefaults: persistence,
            certificateHolderStatus: certificateHolderStatus
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

    func testDefault_WithMaskRuleDate() {
        // Given
        persistence.disableWhatsNew = true
        certificateHolderStatus.latestMaskRuleDate = DateUtils.parseDate("2021-01-26T15:05:00")

        // When
        verifyView(vc: sut)
    }
}
