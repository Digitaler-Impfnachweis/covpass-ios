//
//  File.swift
//  
//
//  Created by Thomas Kuleßa on 09.02.22.
//

import Foundation

open class AppInformationBaseViewModel: AppInformationViewModelProtocol {
    public let router: AppInformationRouterProtocol
    public let title: String
    public let descriptionText: String
    public let appVersionText: String
    open var entries: [AppInformationEntry] { constantEntries }
    private let constantEntries: [AppInformationEntry]

    public init(
        router: AppInformationRouterProtocol,
        entries: [AppInformationEntry],
        title: String = Texts.title,
        descriptionText: String = Texts.description,
        appVersionText: String = Texts.appVersion
    ) {
        self.router = router
        self.title = title
        self.descriptionText = descriptionText
        self.appVersionText = appVersionText
        self.constantEntries = entries
    }

    public func showSceneForEntry(_ entry: AppInformationEntry) {
        router.showScene(entry.scene)
    }
}

extension AppInformationBaseViewModel {
    public enum Texts {
        public static let leichteSprache = NSLocalizedString("app_information_title_company_easy_language", comment: "")
        public static let contactTitle = NSLocalizedString("app_information_title_contact", comment: "")
        public static let faqTitle = NSLocalizedString("app_information_title_faq", comment: "")
        public static let datenschutzTitle = NSLocalizedString("app_information_title_datenschutz", comment: "")
        public static let companyDetailsTitle = NSLocalizedString("app_information_title_company_details", comment: "")
        public static let openSourceLicenseTitle = NSLocalizedString("app_information_title_open_source", comment: "")
        public static let appInformationTitle = NSLocalizedString("app_information_title_update", comment: "")
        public static let title = NSLocalizedString("app_information_title", comment: "")
        public static let description = NSLocalizedString("app_information_message", comment: "")
        public static let accessibilityStatementTitle = NSLocalizedString("app_information_title_accessibility_statement", comment: "")
        public static let localRulesTitle = NSLocalizedString("app_information_title_local_rules", comment: "")
        public static let appVersion = String(format: "Version %@", Bundle.main.appVersion())
    }
}
