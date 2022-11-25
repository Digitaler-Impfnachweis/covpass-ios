//
//  CertificateImportSelectionItemView.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public final class CertificateImportSelectionItemView: XibView {
    @IBOutlet public var checkmarkButton: UIButton!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var subtitleLabel: UILabel!
    @IBOutlet public var stackView: UIStackView!

    override public func initView() {
        super.initView()

        checkmarkButton.setImage(.checkboxChecked, for: .selected)
        checkmarkButton.setImage(.checkboxUnchecked, for: .normal)
        checkmarkButton.setTitle("", for: .normal)
    }
}
