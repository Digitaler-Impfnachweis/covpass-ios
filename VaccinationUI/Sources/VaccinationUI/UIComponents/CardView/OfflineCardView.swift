//
//  OfflineCardView.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class OfflineCardView: BaseCardView {
    // MARK: - Outlets

    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var textLable: UILabel!
    @IBOutlet public var infoImageView: UIImageView!
    @IBOutlet public var infoLabel: UILabel!
    @IBOutlet public var dateLabel: UILabel!
    
    public override func initView() {
        super.initView()
        // TODO add QR code icon
//        actionButton.iconImage = UIImage(named: "", in: <#T##Bundle?#>, with: <#T##UIImage.Configuration?#>)
    }
}
