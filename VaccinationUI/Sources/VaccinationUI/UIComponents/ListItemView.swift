//
//  File.swift
//  
//
//  Created by Sebastian Maschinski on 06.05.21.
//

import UIKit

public class ListItemView: XibView {
    // MARK: - Properties

    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var textLabel: UILabel!
    @IBOutlet var seperatorView: UIView!
    @IBOutlet var internalButton: UIButton!

    var showSeperator: Bool = false {
        didSet {
            seperatorView.isHidden = showSeperator == false
        }
    }

    public var action: (() -> Void)?

    // MARK: - Lifecycle

    public override func initView() {
        super.initView()
        layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
        backgroundColor = .neutralWhite
        textLabel.text = ""
        imageView.image = .chevronRight
        seperatorView.backgroundColor = .onBackground70
    }

    // MARK: - Methods

    @IBAction func didTapButton() {
        action?()
    }
}
