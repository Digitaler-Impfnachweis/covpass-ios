//
//  File.swift
//  
//
//  Created by Sebastian Maschinski on 06.05.21.
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
    required public init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundPrimary
        configureDescription()
        configureAppVersion()
        configureEntries()
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
        view.showSeperator = true
        view.action = { [weak self] in
            self?.viewModel.showSceneForEntry(entry)
        }
        return view
    }
}
