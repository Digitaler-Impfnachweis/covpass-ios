//
//  File.swift
//  
//
//  Created by Sebastian Maschinski on 06.05.21.
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
        "Version 1.0".localized
    }

    public lazy var entries: [AppInformationEntry] = {
        [
            webEntry(title: "Häufige Fragen", url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/client-app/faq/")!),
            webEntry(title: "Datenschutzerklärung", url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/client-app/privacy/")!),
            webEntry(title: "Impressum", url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/imprint/")!),
            entry(title: "Open Source Lizenzen", url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/client-app/faq/")!)
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

    private func entry(title: String, url: URL) -> AppInformationEntry {
        AppInformationEntry(
            title: title,
            scene: WebviewSceneFactory(title: title, url: url)
        )
    }
}
