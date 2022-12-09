//
//  AcousticFeedbackSettingsViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import XCTest

class AcousticFeedbackSettingsViewControllerSnapshotTests: BaseSnapShotTests {
    private var viewModel: AcousticFeedbackSettingsViewModel!
    private var sut: AcousticFeedbackSettingsViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = .init(
            audioPlayer: AudioPlayerMock(),
            persistence: MockPersistence(),
            router: AcousticFeedbackSettingsRouterMock()
        )
        sut = .init(viewModel: viewModel)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testExample_enableAcousticFeedback_on() {
        // Given
        viewModel.enableAcousticFeedback = true

        // Then
        verifyView(view: sut.view)
    }

    func testExample_enableAcousticFeedback_off() {
        // Given
        viewModel.enableAcousticFeedback = false

        // Then
        verifyView(view: sut.view)
    }
}
