//
//  AppInformationViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation

private enum Constants {
    enum Text {
        static let leichteSprache = "app_information_title_company_easy_language".localized
    }
    enum WebLink {
        static let leichteSprache = URL(string: "https://digitaler-impfnachweis-app.de/webviews/leichte-sprache/covpasscheckapp")!
    }
}

class AppInformationViewModel: AppInformationViewModelProtocol {
    // MARK: - Properties

    let router: AppInformationRouterProtocol
    private let userDefaults: Persistence

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

    var entries: [AppInformationEntry] {
        var _entries =
        [
            webEntry(
                title: "app_information_title_contact".localized,
                url: Bundle.main.url(forResource: Locale.current.isGerman() ? "contact-covpasscheck-de" : "contact-covpasscheck-en", withExtension: "html")!
            ),

            webEntry(
                title: "app_information_title_faq".localized,
                url: URL(string: Locale.current.isGerman() ? "https://www.digitaler-impfnachweis-app.de/webviews/verification-app/faq/" : "https://www.digitaler-impfnachweis-app.de/en/webviews/client-app/faq/")!
            ),

            webEntry(
                title: "app_information_title_datenschutz".localized,
                url: Bundle.main.url(forResource: Locale.current.isGerman() ? "privacy-covpasscheck-de" : "privacy-covpasscheck-en", withExtension: "html")!
            ),

            webEntry(
                title: "app_information_title_company_details".localized,
                url: URL(string: Locale.current.isGerman() ? "https://www.digitaler-impfnachweis-app.de/webviews/imprint/" : "https://www.digitaler-impfnachweis-app.de/en/webviews/imprint/")!
            ),

            webEntry(
                title: "app_information_title_open_source".localized,
                url: Bundle.commonBundle.url(forResource: Locale.current.isGerman() ? "license_de" : "license_en", withExtension: "html")!
            ),
            
            AppInformationEntry(
                title: "app_information_title_update".localized,
                scene: TrustedListDetailsSceneFactory(sceneCoordinator: router.sceneCoordinator)
            ),
            
            AppInformationEntry(
                title: "app_information_title_local_rules".localized,
                scene: CheckSituationSceneFactory(contextType: .settings,
                                                  userDefaults: userDefaults),
                rightTitle: checkSituationInfo
            )
        ]
        if Locale.current.isGerman() {
            _entries.insert(webEntry(
                title: Constants.Text.leichteSprache,
                url: Constants.WebLink.leichteSprache
            ), at: 0)
        }
        return _entries
    }
    
    private var checkSituationInfo: String {
        switch userDefaults.selectedLogicType {
        case .de: return "app_information_title_local_rules_status_DE".localized
        case .eu: return "app_information_title_local_rules_status_EU".localized
        case .booster: return ""
        }
    }

    // MARK: - Lifecycle

    init(router: AppInformationRouterProtocol,
         userDefaults: Persistence) {
        self.router = router
        self.userDefaults = userDefaults
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
