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
    
    @IBOutlet weak var headerView: InfoHeaderView!
    @IBOutlet weak var contentStackView: UIStackView!
    
    // MARK: - Properties
    
    private(set) var viewModel: StateSelectionViewModelProtocol
    
    // MARK: - Lifecycle
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }
    
    public init(viewModel: StateSelectionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .uiBundle)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: private methods
    
    private func setupViews() {
        headerView.attributedTitleText = viewModel.pageTitle.styledAs(.header_2)
        headerView.actionButton.setImage(.close, for: .normal)
        viewModel.states.forEach { state in
            guard state.code.localized(bundle: .main) != state.code else {
                return
            }
            let view = CountryItemView()
            view.leftIcon.image =  nil
            view.leftIcon.isHidden =  true
            view.rightIcon.image = .chevronRight
            view.textLabel.attributedText = state.code.localized(bundle: .main).styledAs(.header_3)
            view.action = {
                self.viewModel.choose(state: state.code)
            }
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
