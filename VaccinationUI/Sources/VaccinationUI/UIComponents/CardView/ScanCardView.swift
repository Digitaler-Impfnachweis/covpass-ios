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

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var textStackView: UIStackView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var textLabel: UILabel!
    @IBOutlet public var actionButton: MainButton!
    
    public override func initView() {
        super.initView()
        contentView?.layoutMargins = .init(top: .space_18, left: .space_24, bottom: .space_40, right: .space_24)
        contentView?.backgroundColor = .brandBase
        actionButton.style = .secondary
        actionButton.icon = .scan
        // TODO add QR code icon
//        actionButton.iconImage = UIImage(named: "", in: <#T##Bundle?#>, with: <#T##UIImage.Configuration?#>)
    }
}
