//
//  CertificateViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationUI
import Scanner

public class CertificateViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet public var headerView: InfoHeaderView!
    @IBOutlet public var addButton: PrimaryIconButtonContainer!
    @IBOutlet public var showAllButton: UIButton!
    @IBOutlet public var showAllLabel: UILabel!
    @IBOutlet public var tableView: UITableView!
    @IBOutlet public var stackView: UIStackView!
    
    // MARK: - Public
    
    public var viewModel: CertificateViewModel!
    public var router: Popup?
    
    // MARK: - Private

    private var continerView: UIView!
    
    // MARK: - Fifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView()
        setupOther()
        setupTableView()
        setupOther()
        setupCardViewFor(state: viewModel?.certificateState ?? .none)
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
        addButton.iconImage = viewModel?.addButtonImage
        addButton.buttonBackgroundColor = UIConstants.BrandColor.brandAccent
        addButton.action = presentPopup
    }
    
    // MARK: - Card View
    
    func noCertificateCardView() -> NoCertificateCardView {
        let noCertificate = NoCertificateCardView(frame: CGRect(origin: stackView.bounds.origin, size: CGSize(width: stackView.bounds.width, height: viewModel.continerHeight)))
        noCertificate.actionButton.title = viewModel.noCertificateCardTitle
        noCertificate.cornerRadius = viewModel.continerCornerRadius
        noCertificate.actionButton.action = presentPopup
        return noCertificate
    }
    
    func halfCertificateCardView() -> PartialCertificateCardView {
        let certificate = PartialCertificateCardView(frame: CGRect(origin: stackView.bounds.origin, size: CGSize(width: stackView.bounds.width, height: viewModel.continerHeight)))
        certificate.actionButton.title = viewModel.halfCertificateCardTitle
        certificate.cornerRadius = viewModel.continerCornerRadius
        certificate.actionButton.action = presentPopup
        return certificate
    }
    
    func fullCertificateCardView() -> UIView {
        // TBD - we should update with actual card view
        UIView(frame: CGRect(origin: stackView.bounds.origin, size: CGSize(width: stackView.bounds.width, height: viewModel.continerHeight)))
    }
    
    func setupCardViewFor(state: CertificateState) {
        if continerView != nil {
            stackView.removeArrangedSubview(continerView)
        }
        switch state {
        case .none:
            continerView = noCertificateCardView()
        case .half:
            continerView = halfCertificateCardView()
        case .full:
            continerView = fullCertificateCardView()
        }
        stackView.insertArrangedSubview(continerView, at: stackView.arrangedSubviews.count - 1)
    }
    
    func presentPopup() {
        router?.presentPopup(onTopOf: self)
    }
}

// MARK: - ScannerDelegate

extension CertificateViewController: ScannerDelegate {
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

extension CertificateViewController: UITableViewDataSource {
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

extension CertificateViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: - show smth
    }
}

// MARK: - StoryboardInstantiating

extension CertificateViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        return VaccinationPassConstants.Storyboard.Pass
    }
}

// MARK: - CertificateStateDelegate

extension CertificateViewController: CertificateStateDelegate {
    public func didUpdatedCertificate(state: CertificateState) {
        setupCardViewFor(state: state)
    }
}
