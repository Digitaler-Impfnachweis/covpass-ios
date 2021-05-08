//
//  ConsentViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import WebKit

class ConsentViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var headline: PlainLabel!
    @IBOutlet var descriptionText: PlainLabel!
    @IBOutlet var dataPrivacyCheckbox: CheckboxView!

    // MARK: - Properties

    private(set) var viewModel: ConsentPageViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    public init(viewModel: ConsentPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentInset.top = .space_70
        configureImageView()
        configureHeadline()
        configureParagraphView()
        configureCheckboxes()
    }

    // MARK: - Methods

    private func configureImageView() {
        imageView.image = viewModel.image
        imageView.pinHeightToScaleAspectFit()
    }

    private func configureHeadline() {
        headline.attributedText = viewModel.title?.styledAs(.header_2)
        headline.layoutMargins = .init(top: .space_40, left: .space_24, bottom: .zero, right: .space_24)
    }

    private func configureParagraphView() {
        descriptionText.attributedText = viewModel.info?.styledAs(.body).colored(.onBackground70)
        descriptionText.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .zero, right: .space_24)
    }

    private func configureCheckboxes() {
        dataPrivacyCheckbox.textView.attributedText = viewModel.dataPrivacyTitle
        dataPrivacyCheckbox.layoutMargins = .init(top: .space_40, left: .space_24, bottom: .zero, right: .space_24)
        dataPrivacyCheckbox.didChangeState = { [weak self] in
            self?.viewModel.isGranted = $0
        }
    }
}
