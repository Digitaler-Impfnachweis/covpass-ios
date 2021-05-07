//
//  PassAppInformationViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import VaccinationUI

public class PassAppInformationViewModel: AppInformationViewModelProtocol {
    // MARK: - Properties

    public let router: AppInformationRouterProtocol

    public var title: String {
        "Informationen".localized
    }

    public var descriptionText: String {
        "Alle Informationen zur Impfnachweis-App im Überblick:".localized
    }

    public var appVersionText: String {
        String(
            format: "Version %@".localized,
            Bundle.module.appVersion()
        )
    }

    public lazy var entries: [AppInformationEntry] = {
        [
            webEntry(
                title: "Häufige Fragen".localized,
                url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/client-app/faq/")!),

            webEntry(
                title: "Datenschutzerklärung".localized,
                url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/client-app/privacy/")!),

            webEntry(
                title: "Impressum".localized,
                url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/imprint/")!),

            // TODO: Needs a scene to display localized texts from bundle. 
            webEntry(
                title: "Open Source Lizenzen".localized,
                url: URL(string: "https://www.digitaler-impfnachweis-app.de/")!)
        ]
    }()

    // MARK: - Lifecycle

    public init(router: AppInformationRouterProtocol) {
        self.router = router
    }

    // MARK: - Methods

    public func showSceneForEntry(_ entry: AppInformationEntry) {
        router.showScene(entry.scene)
    }

    private func webEntry(title: String, url: URL) -> AppInformationEntry {
        AppInformationEntry(
            title: title,
            scene: WebviewSceneFactory(title: title, url: url)
        )
    }
}
