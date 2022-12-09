//
//  RevocationSettingsViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import UIKit

class RevocationSettingsViewControllerSnapShotTests: BaseSnapShotTests {
    var sut: UIViewController!
    var persistence: UserDefaultsPersistence!

    override func setUpWithError() throws {
        persistence = UserDefaultsPersistence()
        sut = RevocationSettingsSceneFactory(router: RevocationSettingsRouterMock(), userDefaults: persistence).make()
    }

    override func tearDown() {
        persistence = nil
        sut = nil
    }

    func testDefaultOnboarding() {
        try? persistence.delete(UserDefaults.keyRevocationExpertMode)
        verifyView(view: sut.view)
    }

    func testDefaultOnboarding_True() {
        persistence.revocationExpertMode = true
        verifyView(view: sut.view)
    }

    func testDefaultOnboarding_False() {
        persistence.revocationExpertMode = false
        verifyView(view: sut.view)
    }
}
