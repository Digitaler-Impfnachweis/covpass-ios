//
//  ContainerViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

open class ContainerViewController: UIViewController {
    // MARK: - Properties

    @IBOutlet var headerView: InfoHeaderView!
    @IBOutlet var containerView: UIView!

    let viewModel: ContainerViewModelProtocol

    // MARK: - Lifecycle

    public init(viewModel: ContainerViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
        title = viewModel.title
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .neutralWhite
        configureHeader()
        configureContainer()
    }

    // MARK: - Methods

    private func configureHeader() {
        headerView.attributedTitleText = viewModel.title.styledAs(.header_1)
        headerView.image = .close
        headerView.textLabel.enableAccessibility(label: viewModel.title, traits: .header)
        headerView.action = viewModel.close
    }

    private func configureContainer() {
        let childViewController = viewModel.embeddedViewController.make()
        addChild(childViewController)
        containerView.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
    }
}
