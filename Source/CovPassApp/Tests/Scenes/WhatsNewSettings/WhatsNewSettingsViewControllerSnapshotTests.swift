//
//  WhatsNewSettingsViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

class WhatsNewSettingsViewControllerSnapshotTests: BaseSnapShotTests {
    private var sut: WhatsNewSettingsViewController!
    private var viewModel: WhatsNewSettingsViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()

        viewModel = .init(
            persistence: MockPersistence(),
            whatsNewURL: FileManager.default.temporaryDirectory
        )
        sut = .init(viewModel: viewModel)
    }

    override func tearDownWithError() throws {
        sut = nil
        viewModel = nil

        try super.tearDownWithError()
    }

    func testDefault() {
        // Given
        viewModel.disableWhatsNew = true

        // Then
        verifyView(vc: sut)
    }

    func testSwitchOn() {
        // Then
        verifyView(vc: sut)
    }
}
