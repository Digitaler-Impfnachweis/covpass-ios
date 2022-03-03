//
//  AppInformationViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import Foundation

class GermanAppInformationViewModel: AppInformationBaseViewModel {
    init(
        router: AppInformationRouterProtocol,
        mainBundle: Bundle = .main,
        licenseBundle: Bundle = .commonBundle
    ) {
        let entries = [
            .webEntry(title: Texts.leichteSprache, url: URL(string: "https://digitaler-impfnachweis-app.de/webviews/leichte-sprache/covpassapp")!),
            .webEntry(title: Texts.contactTitle, url: mainBundle.url(forResource: "contact-covpass-de", withExtension: "html")!),
            .webEntry(title: Texts.faqTitle, url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/client-app/faq/")!),
            .webEntry(title: Texts.datenschutzTitle, url: mainBundle.url(forResource: "privacy-covpass-de", withExtension: "html")!),
            .webEntry(title: Texts.companyDetailsTitle, url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/imprint/")!),
            .webEntry(title: Texts.openSourceLicenseTitle, url: licenseBundle.url(forResource: "license_de", withExtension: "html")!),
            .webEntry(title: Texts.accessibilityStatementTitle, url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/covpass-app-ios-barrierefreiheitserklaerung/")!),
            AppInformationEntry(title: Texts.appInformationTitle, scene: TrustedListDetailsSceneFactory(sceneCoordinator: router.sceneCoordinator))
        ]
        super.init(router: router, entries: entries)
    }
}

class EnglishAppInformationViewModel: AppInformationBaseViewModel {
    init(
        router: AppInformationRouterProtocol,
        mainBundle: Bundle = .main,
        licenseBundle: Bundle = .commonBundle
    ) {
        let entries = [
            .webEntry(title: Texts.contactTitle, url: mainBundle.url(forResource: "contact-covpass-en", withExtension: "html")!),
            .webEntry(title: Texts.faqTitle, url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/client-app/faq/")!),
            .webEntry(title: Texts.datenschutzTitle, url: mainBundle.url(forResource: "privacy-covpass-en", withExtension: "html")!),
            .webEntry(title: Texts.companyDetailsTitle, url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/imprint/")!),
            .webEntry(title: Texts.openSourceLicenseTitle, url: licenseBundle.url(forResource: "license_en", withExtension: "html")!),
            .webEntry(title: Texts.accessibilityStatementTitle, url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/covpass-app-ios-accessibility-statement/")!),
            AppInformationEntry(title: Texts.appInformationTitle, scene: TrustedListDetailsSceneFactory(sceneCoordinator: router.sceneCoordinator))
        ]
        super.init(router: router, entries: entries)
    }
}

private extension AppInformationEntry {
    static func webEntry(title: String, url: URL) -> AppInformationEntry {
        .init(
            title: title,
            scene: WebviewSceneFactory(title: title, url: url)
        )
    }
}
