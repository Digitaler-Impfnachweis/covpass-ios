//
//  ValidatorAppInformationViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import VaccinationCommon
import VaccinationUI

class ValidatorAppInformationViewModel: AppInformationViewModelProtocol {
    // MARK: - Properties

    let router: AppInformationRouterProtocol

    var title: String {
        "Informationen".localized
    }

    var descriptionText: String {
        "Alle Informationen zur Prüf-App im Überblick:".localized
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
                title: "Häufige Fragen".localized,
                url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/verification-app/faq/")!
            ),

            webEntry(
                title: "Datenschutzerklärung".localized,
                url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/verification-app/privacy/")!
            ),

            webEntry(
                title: "Impressum".localized,
                url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/imprint/")!
            ),

            webEntry(
                title: "Open Source Lizenzen".localized,
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
