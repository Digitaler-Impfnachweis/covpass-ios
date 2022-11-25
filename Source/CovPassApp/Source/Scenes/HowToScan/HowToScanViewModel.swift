//
//  ProofViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import LocalAuthentication
import PromiseKit
import UIKit

private enum Constants {
    enum Accessibility {
        static let sceneOpeningAnnouncement = "accessibility_certificate_add_popup_announce".localized
        static let sceneClosingAnnouncement = "accessibility_certificate_add_popup_closing_announce".localized
    }
}

class HowToScanViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let router: HowToScanRouterProtocol
    let resolver: Resolver<Void>

    var image: UIImage? {
        .proofScreen
    }

    var title: String {
        "certificate_add_popup_title".localized
    }

    var info: String {
        "certificate_add_popup_message".localized
    }

    var actionTitle: String {
        "certificate_add_popup_action_title".localized
    }

    var startButtonTitle: String { "certificate_add_popup_scan_button_title".localized }

    var sceneOpeningAnnouncement: String = Constants.Accessibility.sceneOpeningAnnouncement

    var sceneClosingAnnouncement: String = Constants.Accessibility.sceneClosingAnnouncement

    var showPasscodeHint: Bool {
        // check if device passcode is set
        !LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }

    // MARK: - Lifecycle

    init(
        router: HowToScanRouterProtocol,
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

    func showMoreInformation() {
        router.showMoreInformation()
    }
}
