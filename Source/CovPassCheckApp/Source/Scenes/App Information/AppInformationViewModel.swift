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

class CheckAppInformationBaseViewModel: AppInformationBaseViewModel {
    override var entries: [AppInformationEntry] {
        super.entries + [checkSituationEntry]
    }

    private let userDefaults: Persistence
    private var checkSituationEntry: AppInformationEntry {
        let checkSituationInfo = userDefaults.selectedLogicType.checkSituationInfo
        let scene = CheckSituationSceneFactory(contextType: .settings, userDefaults: userDefaults)
        return AppInformationEntry(title: LocalText.rulesTitle, scene: scene, rightTitle: checkSituationInfo)
    }

    init(router:AppInformationRouterProtocol, entries: [AppInformationEntry], userDefaults: Persistence) {
        self.userDefaults = userDefaults
        super.init(router: router, entries: entries)
    }
}

class GermanAppInformationViewModel: CheckAppInformationBaseViewModel {
    init(
        router: AppInformationRouterProtocol,
        userDefaults: Persistence,
        mainBundle: Bundle = .main,
        licenseBundle: Bundle = .commonBundle
    ) {
        let entries: [AppInformationEntry] = [
            .webEntry(title: Texts.leichteSprache, url: URL(string: "https://digitaler-impfnachweis-app.de/webviews/leichte-sprache/covpasscheckapp")!),
            .webEntry(title: Texts.contactTitle, url: mainBundle.url(forResource: "contact-covpasscheck-de", withExtension: "html")!),
            .webEntry(title: Texts.faqTitle, url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/verification-app/faq/")!),
            .webEntry(title: Texts.datenschutzTitle, url: mainBundle.url(forResource: "privacy-covpasscheck-de", withExtension: "html")!),
            .webEntry(title: Texts.companyDetailsTitle, url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/imprint/")!),
            .webEntry(title: Texts.openSourceLicenseTitle, url: licenseBundle.url(forResource: "license_de" , withExtension: "html")!),
            .webEntry(title: Texts.accessibilityStatementTitle, url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/covpasscheck-app-ios-barrierefreiheitserklaerung/")!),
            AppInformationEntry(title: Texts.appInformationTitle, scene: TrustedListDetailsSceneFactory(sceneCoordinator: router.sceneCoordinator)),
        ]
        super.init(router: router, entries: entries, userDefaults: userDefaults)
    }
}

class EnglishAppInformationViewModel: CheckAppInformationBaseViewModel {
    init(
        router: AppInformationRouterProtocol,
        userDefaults: Persistence,
        mainBundle: Bundle = .main,
        licenseBundle: Bundle = .commonBundle
    ) {
        let entries: [AppInformationEntry] = [
            .webEntry(title: Texts.contactTitle, url: mainBundle.url(forResource: "contact-covpasscheck-en", withExtension: "html")!),
            .webEntry(title: Texts.faqTitle, url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/client-app/faq/")!),
            .webEntry(title: Texts.datenschutzTitle, url: mainBundle.url(forResource: "privacy-covpasscheck-en", withExtension: "html")!),
            .webEntry(title: Texts.companyDetailsTitle, url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/imprint/")!),
            .webEntry(title: Texts.openSourceLicenseTitle, url: licenseBundle.url(forResource: "license_en" , withExtension: "html")!),
            .webEntry(title: Texts.accessibilityStatementTitle, url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/covpasscheck-app-ios-accessibility-statement/")!),
            AppInformationEntry(title: Texts.appInformationTitle, scene: TrustedListDetailsSceneFactory(sceneCoordinator: router.sceneCoordinator)),
        ]
        super.init(router: router, entries: entries, userDefaults: userDefaults)
    }
}

private enum LocalText {
    static let rulesTitle = "app_information_title_local_rules".localized
}

private extension AppInformationEntry {
    static func webEntry(title: String, url: URL) -> AppInformationEntry {
        .init(
            title: title,
            scene: WebviewSceneFactory(title: title, url: url)
        )
    }
}

private extension DCCCertLogic.LogicType {
    var checkSituationInfo: String {
        switch self {
        case .de: return "app_information_title_local_rules_status_DE".localized
        case .eu: return "app_information_title_local_rules_status_EU".localized
        case .booster: return ""
        }
    }
}
