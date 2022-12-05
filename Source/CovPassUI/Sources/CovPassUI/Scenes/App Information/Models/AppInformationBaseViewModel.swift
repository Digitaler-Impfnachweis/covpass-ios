//
//  AppInformationBaseViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

open class AppInformationBaseViewModel: AppInformationViewModelProtocol {
    public let router: AppInformationRouterProtocol
    public let title: String
    public let descriptionText: String
    public let appVersionText: String
    open var entries: [AppInformationEntry] {
        []
    }

    public let persistence: Persistence
    public let mainBundle: Bundle
    public let licenseBundle: Bundle

    public var whatsNewEntry: AppInformationEntry {
        let router = WhatsNewSettingsRouter(sceneCoordinator: router.sceneCoordinator)
        let scene = WhatsNewSettingsSceneFactory(router: router)
        let rightTitle = persistence.disableWhatsNew ? Texts.whatsNewOff : Texts.whatsNewOn
        return .init(
            title: Texts.whatsNewTitle,
            scene: scene,
            rightTitle: rightTitle
        )
    }

    public init(
        router: AppInformationRouterProtocol,
        title: String = Texts.title,
        descriptionText: String = Texts.description,
        appVersionText: String = Texts.appVersion,
        persistence: Persistence,
        mainBundle: Bundle = .main,
        licenseBundle: Bundle = .commonBundle
    ) {
        self.router = router
        self.title = title
        self.descriptionText = descriptionText
        self.appVersionText = appVersionText
        self.persistence = persistence
        self.mainBundle = mainBundle
        self.licenseBundle = licenseBundle
    }

    public func showSceneForEntry(_ entry: AppInformationEntry) {
        router.showScene(entry.scene)
    }
}

public extension AppInformationBaseViewModel {
    enum Texts {
        public static let whatsNewTitle = "app_information_title_update_notifications".localized(bundle: .main)
        public static let whatsNewOn = "settings_list_status_on".localized(bundle: .main)
        public static let whatsNewOff = "settings_list_status_off".localized(bundle: .main)
        public static let leichteSprache = "app_information_title_company_easy_language".localized(bundle: .main)
        public static let contactTitle = "app_information_title_contact".localized(bundle: .main)
        public static let faqTitle = "app_information_title_faq".localized(bundle: .main)
        public static let datenschutzTitle = "app_information_title_datenschutz".localized(bundle: .main)
        public static let companyDetailsTitle = "app_information_title_company_details".localized(bundle: .main)
        public static let openSourceLicenseTitle = "app_information_title_open_source".localized(bundle: .main)
        public static let appInformationTitle = "app_information_title_update".localized(bundle: .main)
        public static let title = "app_information_title".localized(bundle: .main)
        public static let description = "app_information_message".localized(bundle: .main)
        public static let accessibilityStatementTitle = "app_information_title_accessibility_statement".localized(bundle: .main)
        public static let federalStateTitle = "infschg_settings_federal_state_title".localized(bundle: .main)
        public static let appVersion = String(format: "Version %@", Bundle.main.appVersion())
    }

    enum Accessibility {
        public enum Opening {
            public static let informationAnnounce = "accessibility_app_information_title_information_announce".localized(bundle: .main)
            public static let leichteSprache = "accessibility_app_information_title_simple_language_announce".localized(bundle: .main)
            public static let contactTitle = "accessibility_app_information_title_contact_announce".localized(bundle: .main)
            public static let faqTitle = "accessibility_app_information_title_faq_announce".localized(bundle: .main)
            public static let datenschutzTitle = "accessibility_app_information_datenschutz_announce".localized(bundle: .main)
            public static let companyDetailsTitle = "accessibility_app_information_title_legal_information_announce".localized(bundle: .main)
            public static let openSourceLicenseTitle = "accessibility_app_information_title_open_source_announce".localized(bundle: .main)
            public static let accessibilityStatementTitle = "accessibility_app_information_title_accessibility_statement_announce".localized(bundle: .main)
        }

        public enum Closing {
            public static let informationAnnounce = "accessibility_app_information_title_information_closing_announce".localized(bundle: .main)
            public static let leichteSprache = "accessibility_app_information_title_simple_language_announce_closing".localized(bundle: .main)
            public static let contactTitle = "accessibility_app_information_title_contact_closing_announce".localized(bundle: .main)
            public static let faqTitle = "accessibility_app_information_title_faq_announce_closing".localized(bundle: .main)
            public static let datenschutzTitle = "accessibility_app_information_datenschutz_closing_announce".localized(bundle: .main)
            public static let companyDetailsTitle = "accessibility_app_information_title_legal_information_announce_closing".localized(bundle: .main)
            public static let openSourceLicenseTitle = "accessibility_app_information_title_open_source_announce_closing".localized(bundle: .main)
            public static let accessibilityStatementTitle = "accessibility_app_information_title_accessibility_statement_announce_closing".localized(bundle: .main)
        }
    }
}

public extension AppInformationEntry {
    static func webEntry(title: String,
                         url: URL,
                         enableDynamicFonts: Bool = false,
                         openingAnnounce: String,
                         closingAnnounce: String) -> AppInformationEntry {
        .init(
            title: title,
            scene: WebviewSceneFactory(title: title,
                                       url: url,
                                       enableDynamicFonts: enableDynamicFonts,
                                       openingAnnounce: openingAnnounce,
                                       closingAnnounce: closingAnnounce)
        )
    }
}
