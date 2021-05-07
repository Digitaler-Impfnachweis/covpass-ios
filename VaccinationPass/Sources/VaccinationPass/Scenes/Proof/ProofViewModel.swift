//
//  ProofViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit
import VaccinationUI

class ProofViewModel: BaseViewModel, CancellableViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    let router: ProofRouterProtocol
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
        router: ProofRouterProtocol,
        resolvable: Resolver<Void>) {

        self.router = router
        self.resolver = resolvable
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
