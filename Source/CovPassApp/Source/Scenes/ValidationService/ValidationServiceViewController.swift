//
//  ValidationServiceViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import CovPassUI

private enum Constants {
    enum Text {
        static let headerText = "Ihre Zertifikate zu Buchungszwecken freigeben"
        static let confirmButton = "Einverstanden"
        static let cancelButton = "Abbrechen"
        static let privacyPolicy = "Datenschutzerklärung"
    }
}

class ValidationServiceViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let viewModel: ValidationServiceViewModel

    private lazy var mainButton: MainButton = {
        let button = MainButton()
        button.setConstant(size: CGSize(width: 177, height: 56))
        button.title = Constants.Text.confirmButton
        button.action = {
            self.dismiss(animated: true, completion: nil)
        }
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setConstant(height: 21)
        button.setAttributedTitle(Constants.Text.cancelButton.styledAs(.header_3), for: .normal)
        button.setTitleColor(.brandAccent, for: .normal)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()

    private lazy var headerView: InfoHeaderView = {
        let view = InfoHeaderView()
        view.image = .close
        view.layoutMargins.bottom = .space_24
        view.frame.size.height = 130
        view.attributedTitleText = Constants.Text.headerText.styledAs(.header_3)
        view.action = {
            self.dismiss(animated: true, completion: nil)
        }
        return view
    }()

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ValidationServiceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let footerView = UIView()
        footerView.addSubview(mainButton)
        footerView.addSubview(cancelButton)
        footerView.frame.size.height = 200

        tableView.tableHeaderView = headerView

        tableView.tableFooterView = footerView

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            mainButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 40),
            mainButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            cancelButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            cancelButton.topAnchor.constraint(equalTo: mainButton.bottomAnchor, constant: 24)])

        self.tableView.reloadData()
    }

    @objc func cancel() {        
        viewModel.router.routeToWarning()
    }
}

extension ValidationServiceViewController: UITableViewDelegate {

}

extension ValidationServiceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard var cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            fatalError()
        }
        switch indexPath.row {
        case 0:
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
            cell.textLabel?.text = "Provider"
            cell.detailTextLabel?.text = viewModel.initialisationData.serviceProvider
        case 1:
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
            cell.textLabel?.text = "Subject"
            cell.detailTextLabel?.text = viewModel.initialisationData.subject
        case 2:
            cell.textLabel?.text = viewModel.initialisationData.consent
        case 3:
            cell.textLabel?.text = Constants.Text.privacyPolicy
            cell.accessoryType = .disclosureIndicator
        default:
            fatalError()
        }
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
}
