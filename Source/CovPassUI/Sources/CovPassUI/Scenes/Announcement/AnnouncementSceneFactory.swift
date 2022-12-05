//
//  AnnouncementSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import UIKit

public struct AnnouncementSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: AnnouncementRouter

    // MARK: - Lifecycle

    public init(router: AnnouncementRouter) {
        self.router = router
    }

    public func make(resolvable: Resolver<Void>) -> UIViewController {
        let bundle = Bundle.commonBundle
        guard let url = Locale.current.isGerman() ? bundle.germanAnnouncementsURL : bundle.englishAnnouncementsURL
        else {
            fatalError("Invalid resource URL.")
        }
        let persistence = UserDefaultsPersistence()
        let viewModel = AnnouncementViewModel(
            router: router,
            resolvable: resolvable,
            persistence: persistence,
            whatsNewURL: url
        )
        return AnnouncementViewController(viewModel: viewModel)
    }
}
