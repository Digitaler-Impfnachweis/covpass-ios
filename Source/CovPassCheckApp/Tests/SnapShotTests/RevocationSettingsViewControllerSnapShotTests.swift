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
    var vc: UIViewController!
    var persistence: UserDefaultsPersistence!

    override func setUpWithError() throws {
        persistence = UserDefaultsPersistence()
        vc = RevocationSettingsSceneFactory(router: RevocationSettingsRouterMock(), userDefaults: persistence).make()
    }

    override func tearDown() {
        persistence = nil
        vc = nil
    }

    func testDefaultOnboarding() {
        try? persistence.delete(UserDefaults.keyRevocationExpertMode)
        verifyView(vc: vc)
    }

    func testDefaultOnboarding_True() {
        persistence.revocationExpertMode = true
        verifyView(vc: vc)
    }

    func testDefaultOnboarding_False() {
        persistence.revocationExpertMode = false
        verifyView(vc: vc)
    }
}
