//
//  HintTableViewCell.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import Foundation
import UIKit

class HintTableViewCell: UITableViewCell {

    private lazy var hintView: HintView = {
        let view = HintView()
        view.iconView.image = .infoSignal
        view.containerView.backgroundColor = .brandAccent10
        view.containerView?.layer.borderColor = UIColor.brandAccent20.cgColor        
        return view
    }()

    var titleText: NSAttributedString? {
        didSet {
            hintView.titleLabel.attributedText = titleText
        }
    }

    var bodyText: NSAttributedString? {
        didSet {
            hintView.bodyLabel.attributedText = bodyText
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(hintView)
        hintView.pinEdges(to: contentView)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

}
