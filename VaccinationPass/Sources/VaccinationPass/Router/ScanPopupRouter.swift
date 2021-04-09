//
//  ScanPopupRouter.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationUI
import BottomPopup

public class ScanPopupRouter {
    
    // MARK: - Init
    
    public init() {}
}

// MARK: - Router

extension ScanPopupRouter: Popup {
    
    public func presentPopup(onTopOf viewController: UIViewController) {
        let popupVC = ScanPopupViewController.createFromStoryboard()
        popupVC.popupDelegate = self
        popupVC.viewModel = ScanPopupViewModel()
        viewController.present(popupVC, animated: true, completion: nil)
    }
}

// MARK: - BottomPopupDelegate

extension ScanPopupRouter: BottomPopupDelegate {
    public func bottomPopupViewLoaded(){}
    public func bottomPopupWillAppear(){}
    public func bottomPopupDidAppear(){}
    public func bottomPopupWillDismiss(){}
    public func bottomPopupDidDismiss(){}
    public func bottomPopupDismissInteractionPercentChanged(from oldValue: CGFloat, to newValue: CGFloat){}
}

