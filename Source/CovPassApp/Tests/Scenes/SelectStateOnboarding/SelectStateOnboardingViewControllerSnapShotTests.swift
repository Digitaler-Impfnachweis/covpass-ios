//
//  SelectStateOnboardingViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassUI
import PromiseKit
import UIKit

class SelectStateOnboardingViewControllerSnapShotTests: BaseSnapShotTests {
    private var sut: SelectStateOnboardingViewController!
    private var persistence: MockPersistence!
    private var router: SelectStateOnboardingViewRouter!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let (_, resolver) = Promise<Void>.pending()
        persistence = .init()
        router = SelectStateOnboardingViewRouter(sceneCoordinator: SceneCoordinatorMock())
        let viewModel = SelectStateOnboardingViewModel(resolver: resolver,
                                                       router: router,
                                                       userDefaults: persistence)
        sut = .init(viewModel: viewModel)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testDefault() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        UIApplication.shared.keyWindow?.rootViewController = sut
        verifyView(view: sut.view, height: 1000, waitAfter: 0.6)
    }
}
