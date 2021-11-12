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
        static let headerText = "share_certificate_title".localized
        static let confirmButton = "share_certificate_action_button_agree".localized
        static let cancelButton = "share_certificate_action_button_cancel".localized
        static let privacyPolicy = "app_information_title_datenschutz".localized     
    }

    enum Layout {
        static let cancelButtonHeight: CGFloat = 21
        static let mainButtonSize = CGSize(width: 177, height: 56)
        static let headerViewHeight: CGFloat = 130
        static let footerViewHeight: CGFloat = 200
    }
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
        button.action = { [weak self] in
            self?.cancel()
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
            self?.cancel()
        }
        view.actionButton.enableAccessibility(label: ValidationServiceViewModel.Accessibility.close.label)
        
        return view
    }()

    private lazy var footerView: UIView = {
        let footerView = UIView()
        footerView.frame.size.height = Constants.Layout.footerViewHeight

        let borderView = UIView()
        borderView.backgroundColor = .divider
        borderView.setConstant(height: 1)

        footerView.addSubview(borderView)
        footerView.addSubview(mainButton)
        footerView.addSubview(cancelButton)

        NSLayoutConstraint.activate([borderView.topAnchor.constraint(equalTo: footerView.topAnchor),
                                     borderView.widthAnchor.constraint(equalTo: footerView.widthAnchor)])
        return footerView
    }()

    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView(image: .chevronRight)
        imageView.tintColor = .onBackground100
        return imageView
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

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ValidationServiceViewModel.Rows.additionalInformation.reuseIdentifier)
        tableView.register(HintTableViewCell.self, forCellReuseIdentifier: ValidationServiceViewModel.Rows.hintView.reuseIdentifier)
        tableView.register(SubTitleCell.self, forCellReuseIdentifier: ValidationServiceViewModel.Rows.provider.reuseIdentifier)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .divider

        NSLayoutConstraint.activate([
            mainButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 40),
            mainButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            cancelButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            cancelButton.topAnchor.constraint(equalTo: mainButton.bottomAnchor, constant: 24)])

        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        UIAccessibility.post(notification: .announcement, argument: ValidationServiceViewModel.Accessibility.openViewController.label)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIAccessibility.post(notification: .announcement, argument: ValidationServiceViewModel.Accessibility.closeViewController.label)
    }

    @objc func cancel() {
        viewModel.router.routeToWarning()
    }
}

extension ValidationServiceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == ValidationServiceViewModel.Rows.privacyLink.rawValue {
            viewModel.routeToPrivacyStatement()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}


extension ValidationServiceViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let reuseIdentifier = ValidationServiceViewModel.Rows(rawValue: indexPath.row)?.reuseIdentifier else {
            fatalError("There's something wrong with the tableview - we don't have a reuseidentifier")
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .none
        cell.accessoryView = nil
        cell.isUserInteractionEnabled = false

        switch indexPath.row {
        case ValidationServiceViewModel.Rows.provider.rawValue:

            cell.textLabel?.attributedText = ValidationServiceViewModel.Rows.provider.cellTitle
                .styledAs(.header_3)
            cell.detailTextLabel?.attributedText = viewModel.initialisationData.serviceProvider
                .styledAs(.body)
            cell.separatorInset = UIEdgeInsets.zero
        case ValidationServiceViewModel.Rows.subject.rawValue:
            cell.textLabel?.attributedText = ValidationServiceViewModel.Rows.subject.cellTitle
                .styledAs(.header_3)
            cell.detailTextLabel?.attributedText = viewModel.initialisationData.subject
                .styledAs(.body)
            cell.separatorInset = UIEdgeInsets.zero
        case ValidationServiceViewModel.Rows.consentHeader.rawValue:
            cell.textLabel?.attributedText = viewModel.initialisationData.consent
                .styledAs(.body)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        case ValidationServiceViewModel.Rows.hintView.rawValue:
            if let hintCell = cell as? HintTableViewCell {
                hintCell.titleText = ValidationServiceViewModel.Rows.hintView.cellTitle
                    .styledAs(.header_3)
                hintCell.bodyText = viewModel.hintViewText
            }
        case ValidationServiceViewModel.Rows.additionalInformation.rawValue:
            cell.textLabel?.attributedText = viewModel.additionalInformation
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        case ValidationServiceViewModel.Rows.privacyLink.rawValue:
            cell.isUserInteractionEnabled = true
            cell.textLabel?.attributedText = Constants.Text.privacyPolicy
                .styledAs(.header_3)
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = chevronImageView
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
