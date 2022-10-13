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
        super.entries + [
            checkSituationEntry,
            revocationSettingsEntry,
            acousticFeedbackSettingsEntry
        ]
    }

    private let userDefaults: Persistence
    private var checkSituationEntry: AppInformationEntry {
        let scene = CheckSituationSceneFactory(
            router: CheckSituationRouter(sceneCoordinator: router.sceneCoordinator),
            userDefaults: userDefaults
        )
        return AppInformationEntry(title: LocalText.rulesTitle, scene: scene)
    }
    private var revocationSettingsEntry: AppInformationEntry {
        let rightTitle = userDefaults.revocationExpertMode ? LocalText.revocationHintOn : LocalText.revocationHintOff
        let revocationSettingsRouter: RevocationSettingsRouter = RevocationSettingsRouter(sceneCoordinator: router.sceneCoordinator)
        let scene = RevocationSettingsSceneFactory(router: revocationSettingsRouter, userDefaults: userDefaults)
        return AppInformationEntry(title: LocalText.revocationTitle, scene: scene, rightTitle: rightTitle)
    }
    private var acousticFeedbackSettingsEntry: AppInformationEntry {
        let rightTitle = userDefaults.enableAcousticFeedback ?
            LocalText.acousticFeedbackOn : LocalText.acousticFeedbackOff
        let acousticFeedbackSettingsRouter = AcousticFeedbackSettingsRouter(
            sceneCoordinator: router.sceneCoordinator
        )
        let scene = AcousticFeedbackSettingsSceneFactory(
            router: acousticFeedbackSettingsRouter
        )
        return AppInformationEntry(
            title: LocalText.acousticFeedbackTitle,
            scene: scene,
            rightTitle: rightTitle
        )
    }

    init(router:AppInformationRouterProtocol, userDefaults: Persistence) {
        self.userDefaults = userDefaults
        super.init(router: router)
    }
}

class GermanAppInformationViewModel: CheckAppInformationBaseViewModel {
    private var mainBundle: Bundle
    private var licenseBundle: Bundle

    override var entries: [AppInformationEntry] {
        [
            .webEntry(title: Texts.leichteSprache,
                      url: URL(string: "https://digitaler-impfnachweis-app.de/webviews/leichte-sprache/covpasscheckapp")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.leichteSprache),
            .webEntry(title: Texts.contactTitle,
                      url: mainBundle.url(forResource: "contact-covpasscheck-de", withExtension: "html")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.contactTitle),
            .webEntry(title: Texts.faqTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/verification-app/faq/")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.faqTitle),
            .webEntry(title: Texts.datenschutzTitle,
                      url: mainBundle.url(forResource: "privacy-covpasscheck-de", withExtension: "html")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.datenschutzTitle),
            .webEntry(title: Texts.companyDetailsTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/imprint/")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.companyDetailsTitle),
            .webEntry(title: Texts.openSourceLicenseTitle,
                      url: licenseBundle.url(forResource: "license_de" , withExtension: "html")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.openSourceLicenseTitle),
            .webEntry(title: Texts.accessibilityStatementTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/covpasscheck-app-ios-barrierefreiheitserklaerung/")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.accessibilityStatementTitle),
        ] + super.entries
    }

    init(
        router: AppInformationRouterProtocol,
        userDefaults: Persistence,
        mainBundle: Bundle = .main,
        licenseBundle: Bundle = .commonBundle
    ) {
        self.mainBundle = mainBundle
        self.licenseBundle = licenseBundle
        super.init(router: router, userDefaults: userDefaults)
    }
}

class EnglishAppInformationViewModel: CheckAppInformationBaseViewModel {
    private var mainBundle: Bundle
    private var licenseBundle: Bundle

    override var entries: [AppInformationEntry] {
        [
            .webEntry(title: Texts.contactTitle,
                      url: mainBundle.url(forResource: "contact-covpasscheck-en", withExtension: "html")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.contactTitle),
            .webEntry(title: Texts.faqTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/client-app/faq/")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.faqTitle),
            .webEntry(title: Texts.datenschutzTitle,
                      url: mainBundle.url(forResource: "privacy-covpasscheck-en", withExtension: "html")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.datenschutzTitle),
            .webEntry(title: Texts.companyDetailsTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/imprint/")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.companyDetailsTitle),
            .webEntry(title: Texts.openSourceLicenseTitle,
                      url: licenseBundle.url(forResource: "license_en" , withExtension: "html")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.openSourceLicenseTitle),
            .webEntry(title: Texts.accessibilityStatementTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/covpasscheck-app-ios-accessibility-statement/")!,
                      accessibilityAnnouncement: AccessiblityAnnouncments.accessibilityStatementTitle),
        ] + super.entries
    }

    init(
        router: AppInformationRouterProtocol,
        userDefaults: Persistence,
        mainBundle: Bundle = .main,
        licenseBundle: Bundle = .commonBundle
    ) {
        self.mainBundle = mainBundle
        self.licenseBundle = licenseBundle
        super.init(router: router, userDefaults: userDefaults)
    }
}

private enum LocalText {
    static let rulesTitle = "settings_rules_list_title".localized
    static let revocationTitle = "app_information_authorities_function_title".localized
    static let revocationHintOn = "app_information_authorities_function_state_on".localized
    static let revocationHintOff = "app_information_authorities_function_state_off".localized
    static let acousticFeedbackTitle = "app_information_beep_when_checking_title".localized
    static let acousticFeedbackOn = "app_information_authorities_function_state_on".localized
    static let acousticFeedbackOff = "app_information_authorities_function_state_off".localized
}

private extension AppInformationEntry {
    static func webEntry(title: String,
                         url: URL,
                         accessibilityAnnouncement: String) -> AppInformationEntry {
        .init(
            title: title,
            scene: WebviewSceneFactory(title: title, url: url, accessibilityAnnouncement: accessibilityAnnouncement)
        )
    }
}
