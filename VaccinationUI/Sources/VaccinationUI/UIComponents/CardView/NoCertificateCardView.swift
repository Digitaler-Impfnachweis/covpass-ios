//
//  NoCertificateCardView.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class NoCertificateCardView: BaseCardView {
    // MARK: - Outlets
    
    @IBOutlet public var topImageView: UIImageView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var textLabel: UILabel!
    @IBOutlet public var actionButton: PrimaryButtonContainer!

    // MARK: - Public Properties

    public var titleText: String? {
        didSet {
            titleLabel.text = titleText
        }
    }

    public var detailText: String? {
        didSet {
            textLabel.text = detailText
        }
    }
}
