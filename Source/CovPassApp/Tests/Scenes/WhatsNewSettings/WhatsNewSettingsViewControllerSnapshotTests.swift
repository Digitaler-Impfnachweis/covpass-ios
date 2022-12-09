//
//  WhatsNewSettingsViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassUI
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
        verifyView(view: sut.view)
    }

    func testSwitchOn() {
        // Then
        verifyView(view: sut.view)
    }
}
