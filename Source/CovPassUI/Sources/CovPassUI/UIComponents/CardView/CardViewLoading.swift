//
//  CardViewLoading.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

@IBDesignable
public class CardViewLoading: XibView {
    // MARK: - Outlets

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var titleLabel: PlainLabel!
    @IBOutlet public var subtitleLabel: PlainLabel!

    // MARK: - Lifecycle

    override public func initView() {
        super.initView()
        stackView.spacing = .space_12
    }
}
