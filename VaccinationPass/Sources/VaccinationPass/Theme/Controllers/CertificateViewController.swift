//
//  CertificateViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationUI

public class CertificateViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet public var container: UIView!
    @IBOutlet public var headerView: HeaderView!
    @IBOutlet public var addButton: PrimaryIconButtonContainer!
    @IBOutlet public var showAllButton: UIButton!
    @IBOutlet public var showAllLabel: UILabel!
    @IBOutlet public var tableView: UITableView!
    
    // MARK: - Public
    
    public var viewModel: CertificateViewModel!
    
    // MARK: - Fifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupOther()
        setupTableView()
        setupContinerContent()
        setupOther()
    }
    
    // MARK: - Private
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UINib(nibName: ActionTableViewCell.identifier, bundle: UIConstants.bundle), forCellReuseIdentifier: ActionTableViewCell.identifier)
        tableView.tintColor = UIConstants.BrandColor.brandAccent
    }
    
    private func setupContinerContent() {
        let noCertificate = NoCertificateCardView(frame: container.bounds)
        noCertificate.actionButton.title = "2. Impfung hinzufügen"
        noCertificate.cornerRadius = 20
        noCertificate.actionButton.action = {
            // TODO: - show scan vc
        }
        container.addSubview(noCertificate)
    }
    
    private func setupOther() {
        view.tintColor = UIConstants.BrandColor.brandAccent
        headerView.headline.text = viewModel.title
        addButton.iconImage = viewModel.addButtonImage
        addButton.buttonBackgroundColor = UIConstants.BrandColor.brandAccent
    }
}

// MARK: - UITableViewDataSource

extension CertificateViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.titles.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ActionTableViewCell.identifier, for: indexPath) as? ActionTableViewCell else { return UITableViewCell()
        }
        viewModel.configure(cell: cell, at: indexPath)
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

