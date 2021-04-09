//
//  ProofPopupViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public class ScanPopupViewModel {
    
    public init() {}
    
    // MARK - Popup
    
    let height: CGFloat = UIScreen.main.bounds.height - 100
    let topCornerRadius: CGFloat = 20
    let presentDuration: Double = 0.5
    let dismissDuration: Double = 0.5
    let shouldDismissInteractivelty: Bool = true
}
