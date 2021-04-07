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
    
    @IBOutlet public var partialCardView: PartialCertificateCardView!
    @IBOutlet public var headerView: HeaderView!
    @IBOutlet public var addButton: PrimaryIconButtonContainer!
    @IBOutlet public var showAllButton: UIButton!
    @IBOutlet public var showAllLabel: UILabel!
    @IBOutlet public var tableView: UITableView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        partialCardView.actionButton.title = "2. Impfung hinzufügen"
        headerView.headline.text = "Meine Impfnachweise"
        if #available(iOS 13.0, *) {
            addButton.iconImage = UIImage(systemName: "plus")
        } else {
            // Fallback on earlier versions
        }
        setupTableView()
    }
    
    // MARK: - Private
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UINib(nibName: ActionTableViewCell.identifier, bundle: UIConstants.bundle), forCellReuseIdentifier: ActionTableViewCell.identifier)
    }
}

// MARK: - UITableViewDataSource

extension CertificateViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       3
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActionTableViewCell.identifier, for: indexPath) as? ActionTableViewCell
        cell?.configure(title: "Hello World")
        return cell ?? UITableViewCell()
    }
}

// MARK: - UITableViewDelegate

extension CertificateViewController: UITableViewDelegate {
    
}
