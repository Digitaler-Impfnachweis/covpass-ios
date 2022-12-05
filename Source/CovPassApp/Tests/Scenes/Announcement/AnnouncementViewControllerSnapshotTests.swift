//
//  AnnouncementViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassUI
import PromiseKit
import XCTest

class AnnouncementViewControllerSnapshotTests: BaseSnapShotTests {
    private var sut: AnnouncementViewController!
    private var persistence: MockPersistence!
    private var router: AnnouncementRouter!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let (_, resolver) = Promise<Void>.pending()
        persistence = .init()
        router = AnnouncementRouter(sceneCoordinator: SceneCoordinatorMock())
        let whatsNewURL = try XCTUnwrap(Bundle.commonBundle.englishAnnouncementsURL)
        let viewModel = AnnouncementViewModel(router: router,
                                              resolvable: resolver,
                                              persistence: persistence,
                                              whatsNewURL: whatsNewURL)
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
        verifyView(view: sut.view, height: 1000, waitAfter: 1.0)
    }
}
