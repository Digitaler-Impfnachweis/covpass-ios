//
//  ActionTableViewCell.swift
//
//
//  Copyright © 2018 IBM. All rights reserved.
//

import UIKit

@IBDesignable
public class ActionTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet public var labelHeadline: UILabel!
    @IBOutlet public var iconImageView: UIImageView!
    
    // MARK: - Public
    
    public static let identifier = "ActionTableViewCell"
    
    // MARK: - Lifecycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        labelHeadline.font = UIFont.ibmPlexSansSemiBold(with: 14)
    }
}

// MARK: - ActionCell

extension ActionTableViewCell: ActionCell {
    public func configure(title: String, iconName: String) {
        labelHeadline.text = title
        iconImageView.image = UIImage(named: iconName, in: Bundle.module, compatibleWith: nil)
    }
}
