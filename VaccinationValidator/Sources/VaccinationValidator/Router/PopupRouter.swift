//
//  PopupRouter.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationUI
import BottomPopup
import Scanner

public class ValidatorPopupRouter {
    
    // MARK: - Init
    
    public init() {}
}

// MARK: - Router

extension ValidatorPopupRouter: PopupRouter {
    
    public func presentPopup(onTopOf viewController: UIViewController) {
        let popupVC = ScanPopupViewController.createFromStoryboard()
        popupVC.popupDelegate = self
        popupVC.viewModel = ScanPopupViewModel()
//        popupVC.router = ScanPopupRouter()
        viewController.present(popupVC, animated: true, completion: nil)
    }
}

// MARK: - BottomPopupDelegate

extension ValidatorPopupRouter: BottomPopupDelegate {
    public func bottomPopupViewLoaded(){}
    public func bottomPopupWillAppear(){}
    public func bottomPopupDidAppear(){}
    public func bottomPopupWillDismiss(){}
    public func bottomPopupDidDismiss(){}
    public func bottomPopupDismissInteractionPercentChanged(from oldValue: CGFloat, to newValue: CGFloat){}
}
