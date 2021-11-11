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

        enum HintView {
            static let title = "Ihr Einverständnis"
        }

        enum Cell {
            static let providerTitle = "Provider"
            static let subjectTitle = "Subject"
        }
    }

    enum Layout {
        static let cancelButtonHeight: CGFloat = 21
        static let mainButtonSize = CGSize(width: 177, height: 56)
        static let headerViewHeight: CGFloat = 130
        static let footerViewHeight: CGFloat = 200
    }

    static let reuseIdentifier = "cell"
    static let reuseIdentifierHintCell = "hintCell"
}

class ValidationServiceViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let viewModel: ValidationServiceViewModel

    private lazy var mainButton: MainButton = {
        let button = MainButton()
        button.setConstant(size: Constants.Layout.mainButtonSize)
        button.innerButton.setAttributedTitle(Constants.Text.confirmButton
                                                .styledAs(.header_3)
                                                .colored(.neutralWhite, in: nil), for: .normal)
        button.action = {
            self.dismiss(animated: true, completion: nil)
        }
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setConstant(height: Constants.Layout.cancelButtonHeight)
        button.setAttributedTitle(Constants.Text.cancelButton
                                    .styledAs(.header_3)
                                    .colored(.brandAccent, in: nil), for: .normal)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()

    private lazy var headerView: InfoHeaderView = {
        let view = InfoHeaderView()
        view.image = .close
        view.layoutMargins.bottom = .space_24
        view.frame.size.height = Constants.Layout.headerViewHeight
        view.attributedTitleText = Constants.Text.headerText.styledAs(.header_3)
        view.action = { [weak self] in
            guard let this = self else {return}
            this.cancel()
        }
        return view
    }()

    private lazy var footerView: UIView = {
        let footerView = UIView()
        footerView.addSubview(mainButton)
        footerView.addSubview(cancelButton)
        footerView.frame.size.height = Constants.Layout.footerViewHeight
        return footerView
    }()

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ValidationServiceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.reuseIdentifier)
        tableView.register(HintTableViewCell.self, forCellReuseIdentifier: Constants.reuseIdentifierHintCell)
        tableView.delegate = self
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            mainButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 40),
            mainButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            cancelButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            cancelButton.topAnchor.constraint(equalTo: mainButton.bottomAnchor, constant: 24)])

        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @objc func cancel() {        
        viewModel.router.routeToWarning()
    }
}

extension ValidationServiceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension ValidationServiceViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard var cell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseIdentifier) else {
            return UITableViewCell()
        }
        cell.accessoryType = .none
        cell.textLabel?.text = nil
        cell.textLabel?.attributedText = nil
        cell.detailTextLabel?.text = nil
        cell.detailTextLabel?.attributedText = nil
        cell.textLabel?.numberOfLines = 0
        cell.isUserInteractionEnabled = false

        switch indexPath.row {
        case ValidationServiceViewModel.Rows.provider.rawValue:
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: Constants.reuseIdentifier)
            cell.accessoryType = .none
            cell.isUserInteractionEnabled = false
            cell.textLabel?.attributedText = Constants.Text.Cell.providerTitle.styledAs(.header_3)
            cell.detailTextLabel?.attributedText = viewModel.initialisationData.serviceProvider.styledAs(.body)
        case ValidationServiceViewModel.Rows.subject.rawValue:
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: Constants.reuseIdentifier)
            cell.accessoryType = .none
            cell.isUserInteractionEnabled = false
            cell.textLabel?.attributedText = Constants.Text.Cell.subjectTitle.styledAs(.header_3)
            cell.detailTextLabel?.attributedText = viewModel.initialisationData.subject.styledAs(.body)
        case ValidationServiceViewModel.Rows.consentHeader.rawValue:
            cell.accessoryType = .none
            cell.textLabel?.attributedText = viewModel.initialisationData.consent.styledAs(.body)
        case ValidationServiceViewModel.Rows.hintView.rawValue:
            guard let hintCell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseIdentifierHintCell) as? HintTableViewCell else {
                return UITableViewCell()
            }
            hintCell.titleText = Constants.Text.HintView.title.localized.styledAs(.header_3)
            hintCell.bodyText = viewModel.hintViewText
            cell.isUserInteractionEnabled = false
            return hintCell
        case ValidationServiceViewModel.Rows.additionalInformation.rawValue:
            cell.textLabel?.attributedText = viewModel.additionalInformation
        case ValidationServiceViewModel.Rows.privacyLink.rawValue:
            cell.isUserInteractionEnabled = true            
            cell.textLabel?.attributedText = Constants.Text.privacyPolicy.styledAs(.header_3)
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = UIImageView(image: .chevronRight)
        default:
            return UITableViewCell()
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
