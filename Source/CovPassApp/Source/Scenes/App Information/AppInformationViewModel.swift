//
//  AppInformationViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import Foundation

private enum Constants {
    enum Text {
        static let leichteSprache = "app_information_title_company_easy_language".localized
    }
    enum WebLink {
        static let leichteSprache = URL(string: "https://digitaler-impfnachweis-app.de/webviews/leichte-sprache/covpassapp")!
    }
}

class AppInformationViewModel: AppInformationViewModelProtocol {
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
            Bundle.main.appVersion()
        )
    }

    lazy var entries: [AppInformationEntry] = {
        [
            webEntry(
                title: Constants.Text.leichteSprache,
                url: Constants.WebLink.leichteSprache
            ),

            webEntry(
                title: "app_information_title_contact".localized,
                url: Bundle.main.url(forResource: Locale.current.isGerman() ? "contact-covpass-de" : "contact-covpass-en", withExtension: "html")!
            ),

            webEntry(
                title: "app_information_title_faq".localized,
                url: URL(string: Locale.current.isGerman() ? "https://www.digitaler-impfnachweis-app.de/webviews/client-app/faq/" : "https://www.digitaler-impfnachweis-app.de/en/webviews/client-app/faq/")!
            ),

            webEntry(
                title: "app_information_title_datenschutz".localized,
                url: Bundle.main.url(forResource: Locale.current.isGerman() ? "privacy-covpass-de" : "privacy-covpass-en", withExtension: "html")!
            ),

            webEntry(
                title: "app_information_title_company_details".localized,
                url: URL(string: Locale.current.isGerman() ? "https://www.digitaler-impfnachweis-app.de/webviews/imprint/" : "https://www.digitaler-impfnachweis-app.de/en/webviews/imprint/")!
            ),

            webEntry(
                title: "app_information_title_open_source".localized,
                url: Bundle.commonBundle.url(forResource: Locale.current.isGerman() ? "license_de" : "license_en", withExtension: "html")!
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
