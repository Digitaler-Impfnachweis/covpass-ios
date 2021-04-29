//
//  ScanCardView.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class ScanCardView: BaseCardView {
    // MARK: - Outlets

    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var textLable: UILabel!
    @IBOutlet public var actionButton: MainButton!
    
    public override func initView() {
        super.initView()
        contentView?.backgroundColor = UIConstants.BrandColor.brandBase
        // TODO add QR code icon
//        actionButton.iconImage = UIImage(named: "", in: <#T##Bundle?#>, with: <#T##UIImage.Configuration?#>)
    }
}
