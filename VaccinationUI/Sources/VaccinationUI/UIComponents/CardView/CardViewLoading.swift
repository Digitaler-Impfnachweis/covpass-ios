//
//  CardViewLoading.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class CardViewLoading: XibView {
    // MARK: - Outlets

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var titleLabel: PlainLabel!
    @IBOutlet public var subtitleLabel: PlainLabel!
    @IBOutlet public var loadingIndicator: DotPulseActivityIndicator!

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        stackView.spacing = .space_12
        loadingIndicator.isHidden = true
        loadingIndicator.color = .neutralWhite
    }
}
