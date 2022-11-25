//
//  StateSelectionViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class StateSelectionViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var headerView: InfoHeaderView!
    @IBOutlet var contentStackView: UIStackView!

    // MARK: - Properties

    private(set) var viewModel: StateSelectionViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    public init(viewModel: StateSelectionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .uiBundle)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.openingAnnounce)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.closingAnnounce)
    }

    // MARK: private methods

    private func setupViews() {
        headerView.attributedTitleText = viewModel.pageTitle.styledAs(.header_2)
        headerView.image = .close
        headerView.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_14)

        headerView.action = { [weak self] in
            self?.viewModel.close()
        }
        let sortedStates = viewModel.states.sorted { state1, state2 in
            let state1CodeWithPrefix = "DE_\(state1.code)".localized(bundle: .main)
            let state2CodeWithPrefix = "DE_\(state2.code)".localized(bundle: .main)
            return state1CodeWithPrefix < state2CodeWithPrefix
        }
        sortedStates.forEach { state in
            let stateCodeWithPrefix = "DE_\(state.code)"
            guard stateCodeWithPrefix.localized(bundle: .main) != state.code else {
                return
            }
            let view = CountryItemView()
            view.leftIcon.image = nil
            view.leftIcon.isHidden = true
            view.rightIcon.image = .chevronRight
            view.textLabel.attributedText = stateCodeWithPrefix.localized(bundle: .main).styledAs(.header_3)
            view.action = {
                let readOut = String(format: self.viewModel.choosenState, stateCodeWithPrefix.localized(bundle: .main))
                UIAccessibility.post(notification: .layoutChanged, argument: readOut)
                self.viewModel.choose(state: state.code)
            }
            view.enableAccessibility(label: stateCodeWithPrefix.localized(bundle: .main), traits: .button)
            contentStackView.addArrangedSubview(view)

            let seperatorView: UIView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setConstant(height: 1)
                view.backgroundColor = .divider
                return view
            }()
            contentStackView.addArrangedSubview(seperatorView)
        }
    }
}
