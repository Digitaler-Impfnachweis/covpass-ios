//
//  AppInformationViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
@testable import CovPassUI
import CovPassCommon

class AppInformationViewControllerSnapShotTests: BaseSnapShotTests {
    private var persistence: MockPersistence!
    private var sut: AppInformationViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        persistence = .init()
        let viewModel = EnglishAppInformationViewModel(
            router: AppInformationRouterMock(),
            userDefaults: persistence
        )
        sut = .init(viewModel: viewModel)
    }

    override func tearDownWithError() throws {
        persistence = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testDefault() {
        verifyView(view: sut.view)
    }
    
    func testDefaultAlternative() {
        // Given
        persistence.revocationExpertMode = true
        persistence.enableAcousticFeedback = true

        // Then
        verifyView(view: sut.view)
    }
}
