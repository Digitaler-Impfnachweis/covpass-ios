//
//  SelectStateOnboardingViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit
import UIKit

class SelectStateOnboardingViewControllerSnapShotTests: BaseSnapShotTests {
    private var sut: SelectStateOnboardingViewController!
    private var persistence: MockPersistence!
    private var certificateHolderStatus: CertificateHolderStatusModelMock!
    private var router: SelectStateOnboardingViewRouter!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let (_, resolver) = Promise<Void>.pending()
        persistence = .init()
        router = SelectStateOnboardingViewRouter(sceneCoordinator: SceneCoordinatorMock())
        certificateHolderStatus = CertificateHolderStatusModelMock()
        let viewModel = SelectStateOnboardingViewModel(
            resolver: resolver,
            router: router,
            userDefaults: persistence,
            certificateHolderStatus: certificateHolderStatus
        )
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

    func testDefault_withMaskRuleDate() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        certificateHolderStatus.latestMaskRuleDate = DateUtils.parseDate("2021-01-26T15:05:00")
        UIApplication.shared.keyWindow?.rootViewController = sut
        verifyView(view: sut.view, height: 1000, waitAfter: 0.6)
    }
}
