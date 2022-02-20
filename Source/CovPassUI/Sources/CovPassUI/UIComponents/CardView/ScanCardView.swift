//
//  ScanCardView.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

public class ScanCardView: XibView {
    // MARK: - Outlets

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var textStackView: UIStackView!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var textLabel: UILabel!
    @IBOutlet public var actionButton: MainButton!
    @IBOutlet var switchWrapperView: UIView!
    @IBOutlet public var switchTextLabel: UILabel!
    @IBOutlet public var uiSwitch: UISwitch!
    
    // MARK: - Properties
    
    public var switchAction: ((Bool) -> Void)?
    public var switchWrapperViewIsHidden: Bool = true {
        didSet {
            switchWrapperView.isHidden = switchWrapperViewIsHidden
            contentView?.clipsToBounds = !switchWrapperViewIsHidden
        }
    }
    private let cornerRadius: CGFloat = 14
    private let shadowRadius: CGFloat = 16
    private let shadowOpacity: CGFloat = 0.2
    private let shadowOffset: CGSize = .init(width: 0, height: -4)

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        contentView?.backgroundColor = .brandBase

        contentView?.layer.cornerRadius = cornerRadius
        contentView?.layer.shadowColor = UIColor.neutralBlack.cgColor
        contentView?.layer.shadowRadius = shadowRadius
        contentView?.layer.shadowOpacity = Float(shadowOpacity)
        contentView?.layer.shadowOffset = shadowOffset

        actionButton.style = .secondary
        actionButton.icon = .scan
        
        switchWrapperView.backgroundColor = .brandBase80
        switchWrapperView.isHidden = switchWrapperViewIsHidden
        uiSwitch.tintColor = .backgroundSecondary
        uiSwitch.layer.cornerRadius = uiSwitch.frame.height / 2.0
        uiSwitch.backgroundColor = .backgroundSecondary
        uiSwitch.clipsToBounds = true
        contentView?.clipsToBounds = !switchWrapperViewIsHidden
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switchAction?(sender.isOn)
    }
    
}
