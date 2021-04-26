//
//  ValidatorViewController.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationUI
import Scanner

public class ValidatorViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet public var headerView: InfoHeaderView!
    @IBOutlet public var showAllButton: UIButton!
    @IBOutlet public var showAllLabel: UILabel!
    @IBOutlet public var tableView: UITableView!
    @IBOutlet public var stackView: UIStackView!
    
    // MARK: - Public
    
    public var viewModel: ValidatorViewModel!
    public var router: PopupRouter?
    
    // MARK: - Private

    private var containerView: UIView!
    
    // MARK: - Fifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView()
        setupOther()
        setupTableView()
        setupOther()
        setupCardView()
    }
    
    // MARK: - Private
    
    public func setupHeaderView() {
        headerView.actionButton.imageEdgeInsets = viewModel.headerButtonInsets
        headerView.headline.text = viewModel?.title
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UINib(nibName: ActionTableViewCell.identifier, bundle: UIConstants.bundle), forCellReuseIdentifier: ActionTableViewCell.identifier)
        tableView.tintColor = UIConstants.BrandColor.brandAccent
    }
    
    private func setupOther() {
        view.tintColor = UIConstants.BrandColor.brandAccent
        headerView.headline.text = viewModel?.title
    }
    
    // MARK: - Card View
    
    func configureCard<T>(_ type: T.Type) -> T where T : BaseCardView {
        let certificate = T(frame: CGRect(origin: stackView.bounds.origin, size: CGSize(width: stackView.bounds.width, height: viewModel.continerHeight)))
        certificate.cornerRadius = viewModel.continerCornerRadius
        return certificate
    }
    
    func setupCardView() {
        if containerView != nil {
            stackView.removeArrangedSubview(containerView)
        }
        
        let card = configureCard(ScanCardView.self)
        card.actionButton.title = "QR Code scannen"
        card.actionButton.action = presentPopup
        
        stackView.insertArrangedSubview(card, at: stackView.arrangedSubviews.count - 1)
    }
    
    func presentPopup() {
        router?.presentPopup(onTopOf: self)
    }
}

// MARK: - ScannerDelegate

extension ValidatorViewController: ScannerDelegate {
    public func result(with value: Result<String, ScanError>) {
        presentedViewController?.dismiss(animated: true, completion: nil)
        switch value {
        case .success(let payload):
            viewModel?.process(payload: payload)
        case .failure(let error):
            print("We have an error: \(error)")
        }
    }
}

// MARK: - UITableViewDataSource

extension ValidatorViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.titles.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ActionTableViewCell.identifier, for: indexPath) as? ActionTableViewCell else { return UITableViewCell()}
        viewModel?.configure(cell: cell, at: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ValidatorViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: - show smth
    }
}

// MARK: - StoryboardInstantiating

extension ValidatorViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        return ValidatorPassConstants.Storyboard.Pass
    }
}
