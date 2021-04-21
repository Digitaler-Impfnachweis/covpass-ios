//
//  NoCertificateCollectionViewCell.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class NoCertificateCollectionViewCell: BaseCardCollectionViewCell {
    // MARK: - IBOutlet
    
    @IBOutlet public var iconImageView: UIImageView!
    @IBOutlet public var headlineLabel: UILabel!
    @IBOutlet public var subHeadlineLabel: UILabel!
    
    // MARK: - Lifecycle
    
    public override func awakeFromNib() {}
}

// MARK: - CellConfigutation

extension NoCertificateCollectionViewCell {
    public typealias T = NoCertifiateConfiguration
    
    public func configure(with configuration: T) {
        headlineLabel.text = configuration.title
        subHeadlineLabel.text = configuration.subtitle
        iconImageView.image = configuration.image
    }
}
