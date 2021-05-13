//
//  PassAppInformationViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import VaccinationUI

class PassAppInformationViewModel: AppInformationViewModelProtocol {
    // MARK: - Properties

    let router: AppInformationRouterProtocol

    var title: String {
        "app_information_title".localized
    }

    var descriptionText: String {
        "app_information_message".localized
    }

    var appVersionText: String {
        String(
            format: "Version %@".localized,
            Bundle.module.appVersion()
        )
    }

    lazy var entries: [AppInformationEntry] = {
        [
            webEntry(
                title: "app_information_title_faq".localized,
                url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/client-app/faq/")!
            ),

            webEntry(
                title: "app_information_title_datenschutz".localized,
                url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/client-app/privacy/")!
            ),

            webEntry(
                title: "app_information_title_company_details".localized,
                url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/imprint/")!
            ),

            webEntry(
                title: "app_information_title_open_source".localized,
                url: Bundle.commonBundle.url(forResource: "license", withExtension: "html")!
            )
        ]
    }()

    // MARK: - Lifecycle

    init(router: AppInformationRouterProtocol) {
        self.router = router
    }

    // MARK: - Methods

    func showSceneForEntry(_ entry: AppInformationEntry) {
        router.showScene(entry.scene)
    }

    private func webEntry(title: String, url: URL) -> AppInformationEntry {
        AppInformationEntry(
            title: title,
            scene: WebviewSceneFactory(title: title, url: url)
        )
    }
}
