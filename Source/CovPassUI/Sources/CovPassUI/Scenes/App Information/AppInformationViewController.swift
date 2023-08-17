//
//  AppInformationViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

open class AppInformationViewController: UIViewController {
    // MARK: - Properties

    @IBOutlet var descriptionLabel: PlainLabel!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var entriesStackView: UIStackView!
    @IBOutlet var versionLabel: PlainLabel!

    let viewModel: AppInformationViewModelProtocol

    // MARK: - Lifecycle

    public init(viewModel: AppInformationViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
        title = viewModel.title
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundPrimary

        let backButton = UIBarButtonItem(image: .arrowBack, style: .done, target: self, action: #selector(backButtonTapped))
        backButton.accessibilityLabel = "accessibility_app_information_contact_label_back".localized // TODO: change accessibility text when they are available
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = .onBackground100

        configureDescription()
        configureAppVersion()
        configureEntries()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIAccessibility.post(notification: .layoutChanged,
                             argument: AppInformationBaseViewModel.Accessibility.Opening.informationAnnounce)
        configureEntries()
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIAccessibility.post(notification: .layoutChanged,
                             argument: AppInformationBaseViewModel.Accessibility.Closing.informationAnnounce)
    }

    // MARK: - Methods

    private func configureDescription() {
        descriptionLabel.attributedText = viewModel.descriptionText.styledAs(.body)
        descriptionLabel.layoutMargins = .init(top: .space_24, left: .space_24, bottom: .space_24, right: .space_24)
    }

    private func configureAppVersion() {
        versionLabel.attributedText = viewModel.appVersionText.styledAs(.body).colored(.onBackground70).aligned(to: .center)
        versionLabel.layoutMargins = .init(top: .space_24, left: .space_24, bottom: .space_24, right: .space_24)
    }

    private func configureEntries() {
        entriesStackView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        viewModel.entries.forEach { entry in
            entriesStackView.addArrangedSubview(entryView(for: entry))
        }
        let flexibleView = UIView()
        flexibleView.setContentHuggingPriority(.defaultLow, for: .vertical)
        flexibleView.backgroundColor = .red
        stackView.addArrangedSubview(flexibleView)
    }

    private func entryView(for entry: AppInformationEntry) -> UIView {
        let view = ListItemView()
        view.textLabel.attributedText = entry.title.styledAs(.header_3)
        view.rightTextLabel.attributedText = entry.rightTitle?.styledAs(.header_3)
        view.showSeperator = true
        view.imageView.image = entry.icon
        view.action = { [weak self] in
            self?.viewModel.showSceneForEntry(entry)
        }
        return view
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
