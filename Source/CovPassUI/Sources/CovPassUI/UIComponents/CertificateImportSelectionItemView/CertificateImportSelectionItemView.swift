//
//  CertificateImportSelectionItemView.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public final class CertificateImportSelectionItemView: XibView {
    @IBOutlet public weak var checkmarkButton: UIButton!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var subtitleLabel: UILabel!
    @IBOutlet public weak var stackView: UIStackView!

    public override func initView() {
        super.initView()

        checkmarkButton.setImage(.checkboxChecked, for: .selected)
        checkmarkButton.setImage(.checkboxUnchecked, for: .normal)
        checkmarkButton.setTitle(nil, for: .normal)
    }
}
