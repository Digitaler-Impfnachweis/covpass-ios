//
//  NoCertificateCollectionViewCell.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

public typealias NoCertificateCardViewModelProtocol = CardViewModel & NoCertificateCardViewModelBase

public protocol NoCertificateCardViewModelBase {
    var title: String { get }
    var subtitle: String { get }
    var image: UIImage { get }
}

@IBDesignable
public class NoCertificateCollectionViewCell: CardCollectionViewCell {
    // MARK: - IBOutlet

    @IBOutlet public var containerView: UIView!
    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var iconImageView: UIImageView!
    @IBOutlet public var headlineLabel: UILabel!
    @IBOutlet public var subHeadlineLabel: UILabel!

    // MARK: - Properties

    override public var viewModel: CardViewModel? {
        didSet {
            updateView()
        }
    }

    private let cornerRadius: CGFloat = 15

    // MARK: - Lifecycle

    override public func awakeFromNib() {
        super.awakeFromNib()

        containerView.layoutMargins = .init(
            top: .space_120,
            left: .space_40,
            bottom: .space_120,
            right: .space_40
        )
        containerView.layer.cornerRadius = cornerRadius

        stackView.spacing = .zero
        stackView.setCustomSpacing(.space_30, after: iconImageView)
    }

    private func updateView() {
        guard let vm = viewModel as? NoCertificateCardViewModelProtocol else { return }

        containerView.backgroundColor = vm.backgroundColor
        containerView.tintColor = vm.backgroundColor
        iconImageView.image = vm.image

        headlineLabel.attributedText = vm.title
            .styledAs(.header_3)
            .aligned(to: .center)

        subHeadlineLabel.attributedText = vm.subtitle
            .styledAs(.body)
            .colored(.onBackground70)
            .aligned(to: .center)
    }
}
