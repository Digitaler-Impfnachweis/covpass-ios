//
//  NoCertificateCollectionViewCell.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
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

    // MARK: - Public Properties

    public override var viewModel: CardViewModel? {
        didSet {
            updateView()
        }
    }
    
    // MARK: - Lifecycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layoutMargins = .init(
            top: .space_120,
            left: .space_40,
            bottom: .space_120,
            right: .space_40
        )
        containerView.layer.cornerRadius = 15

        stackView.spacing = .zero
        stackView.setCustomSpacing(.space_10, after: iconImageView)
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
