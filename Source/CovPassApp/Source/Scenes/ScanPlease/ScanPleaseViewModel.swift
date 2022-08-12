//
//  ScanPleaseViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import LocalAuthentication
import PromiseKit
import UIKit

private enum Constants {
    enum Text {
        static let popupTitle = "certificates_start_screen_pop_up_app_reference_title".localized
        static let popupText = "certificate_start_screen_pop_up_app_reference_text".localized
        static let popupLinkDescription = "certificate_popup_checkapp_link_label".localized
        static let popupLinkText = "certificates_start_screen_pop_up_app_reference_hyperlink".localized
        static let buttonOkText = "certificates_start_screen_pop_up_app_reference_button".localized
    }
    enum Accessibility {
        static let image = "accessibility_image_alternative_text".localized
        static let openingAnnounce = "accessibility_certificate_popup_checkapp_announce".localized
        static let close = "accessibility_certificates_start_screen_pop_up_app_reference_label".localized
    }

}

class ScanPleaseViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let router: ScanPleaseRoutable
    let resolver: Resolver<Void>
    var title: String { Constants.Text.popupTitle }
    var text: String { Constants.Text.popupText }
    var linkDescription: String { Constants.Text.popupLinkDescription }
    var linkText: String { Constants.Text.popupLinkText }
    var buttonOkText: String { Constants.Text.buttonOkText }
    var accessibilityImage: String { Constants.Accessibility.image }
    var accessibilityOpeningAnnounce: String { Constants.Accessibility.openingAnnounce }
    var accessibilityClose: String { Constants.Accessibility.close }

    // MARK: - Lifecycle

    init(
        router: ScanPleaseRoutable,
        resolvable: Resolver<Void>
    ) {
        self.router = router
        resolver = resolvable
    }

    func done() {
        resolver.fulfill_()
    }

    func cancel() {
        resolver.cancel()
    }

    func openCheckPassLink() {
        router.routeToCheckApp()
    }
}
