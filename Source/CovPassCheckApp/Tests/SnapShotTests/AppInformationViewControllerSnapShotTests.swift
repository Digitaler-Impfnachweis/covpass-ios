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
        // Given
        persistence.selectedLogicType = .de

        // Then
        verifyView(vc: sut)
    }
    
    func testDefaultAlternative() {
        // Given
        persistence.selectedLogicType = .eu
        persistence.revocationExpertMode = true
        persistence.enableAcousticFeedback = true

        // Then
        verifyView(vc: sut)
    }
}
