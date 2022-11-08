//
//  NewRegulationsAnnouncementViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit

private enum Constants {
    static let header = "infschg_info_title".localized(bundle: .main)
    static let copyText1 = "infschg_info_copy_1".localized(bundle: .main)
    static let subtitle = "infschg_info_copy_2".localized(bundle: .main)
    static let copyText2 = "infschg_info_copy_3".localized(bundle: .main)
    static let buttonTitle = "infschg_info_button".localized(bundle: .main)
    public enum Accessibility {
        static let openingAnnounce = "accessibility_popup_new_rules_announce".localized(bundle: .main)
        static let closingAnnounce = "accessibility_popup_new_rules_closing_announce".localized(bundle: .main)
    }
}

public final class NewRegulationsAnnouncementViewModel: NewRegulationsAnnouncementViewModelProtocol {
    public let header = Constants.header
    public let illustration: UIImage = .illustrationImpfschutzgesetz
    public let copyText1 = Constants.copyText1
    public let subtitle = Constants.subtitle
    public let copyText2 = Constants.copyText2
    public let buttonTitle = Constants.buttonTitle
    public var openingAnnounce = Constants.Accessibility.openingAnnounce
    public var closingAnnounce = Constants.Accessibility.closingAnnounce

    private let resolver: Resolver<Void>

    public init(resolver: Resolver<Void>) {
        self.resolver = resolver
    }

    public func close() {
        resolver.fulfill_()
    }
}
