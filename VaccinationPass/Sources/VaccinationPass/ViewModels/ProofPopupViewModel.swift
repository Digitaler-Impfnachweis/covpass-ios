//
//  ProofPopupViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit
import VaccinationUI

public class ProofPopupViewModel: BaseViewModel {
    // MARK: - Properties

    public weak var delegate: ViewModelDelegate?
    let router: ProofRouterProtocol
    let resolver: Resolver<Void>

    public var image: UIImage? {
        .proofScreen
    }

    public var title: String {
        "vaccination_add_popup_title".localized
    }

    public var info: String {
        "vaccination_add_popup_message".localized
    }
    
    var actionTitle: String {
        "vaccination_add_popup_action_title".localized
    }
    
    var startButtonTitle: String { "vaccination_add_popup_scan_button_title".localized }
    
    var closeButtonImage: UIImage? {
        .close
    }
    
    var chevronRightImage: UIImage? {
        .chevronRight
    }

    // MARK: - Settings

    public var backgroundColor: UIColor { .backgroundPrimary }
    var tintColor: UIColor { .brandAccent }
    
    // MARK: - Lifecycle

    public init(
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
