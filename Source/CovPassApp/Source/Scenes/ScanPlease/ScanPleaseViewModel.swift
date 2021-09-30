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
        static let popupText = "certificates_start_screen_pop_up_app_reference_text".localized
        static let popupLinkDescription = "certificate_popup_checkapp_link_label".localized
        static let popupLinkText = "certificates_start_screen_pop_up_app_reference_hyperlink".localized
    }
}

class ScanPleaseViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let router: ScanPleaseRoutable
    let resolver: Resolver<Void>

    var title: String {
        Constants.Text.popupTitle
    }

    var text: String {
        Constants.Text.popupText
    }

    var linkDescription: String {
        Constants.Text.popupLinkDescription
    }

    var linkText: String {
        Constants.Text.popupLinkText
    }

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
