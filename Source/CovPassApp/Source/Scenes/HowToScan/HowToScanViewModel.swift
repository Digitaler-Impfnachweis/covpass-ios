//
//  ProofViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import CovPassUI

class HowToScanViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let router: HowToScanRouterProtocol
    let resolver: Resolver<Void>

    var image: UIImage? {
        .proofScreen
    }

    var title: String {
        "vaccination_add_popup_title".localized
    }

    var info: String {
        "vaccination_add_popup_message".localized
    }

    var actionTitle: String {
        "vaccination_add_popup_action_title".localized
    }

    var startButtonTitle: String { "vaccination_add_popup_scan_button_title".localized }

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
