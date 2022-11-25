//
//  ConsentExchangeViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

private enum Constants {
    enum Text {
        static let headerText = "share_certificate_transmission_title".localized
        static let confirmButton = "share_certificate_action_button_agree".localized
        static let cancelButton = "share_certificate_action_button_cancel".localized
        static let privacyPolicy = "app_information_title_datenschutz".localized
    }

    enum Layout {
        static let cancelButtonHeight: CGFloat = 21
        static let mainButtonSize = CGSize(width: 177, height: 56)
        static let headerViewHeight: CGFloat = 245
        static let footerViewHeight: CGFloat = 200
    }
}

class ConsentExchangeViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    private let viewModel: ConsentExchangeViewModel

    private let toolbar: CustomToolbarView = .init(frame: .zero)
    private let toolbarCancel: CustomToolbarView = .init(frame: .zero)
    private let activityIndicator = DotPulseActivityIndicator(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
    private let activityIndicatorContainer = UIView()

    private lazy var mainButton: MainButton = {
        let button = MainButton()
        button.setConstant(size: Constants.Layout.mainButtonSize)
        button.innerButton.setAttributedTitle(Constants.Text.confirmButton
            .styledAs(.header_3)
            .colored(.neutralWhite, in: nil), for: .normal)
        button.action = { [weak self] in
            self?.accept()
        }
        return button
    }()

    private lazy var cancelButton: MainButton = {
        let button = MainButton()
        button.setConstant(size: Constants.Layout.mainButtonSize)
        button.innerButton.setAttributedTitle(Constants.Text.cancelButton
            .styledAs(.header_3)
            .colored(.neutralWhite, in: nil), for: .normal)
        button.action = { [weak self] in
            self?.cancel()
        }
        return button
    }()

    private lazy var headerView: InfoHeaderView = {
        let view = InfoHeaderView()
        view.image = .close
        view.frame.size.height = Constants.Layout.headerViewHeight
        view.textLabel.numberOfLines = 0
        view.attributedTitleText = Constants.Text.headerText.styledAs(.header_3)
        view.action = { [weak self] in
            self?.cancel()
        }
        view.actionButton.enableAccessibility(label: ValidationServiceViewModel.Accessibility.close.label)

        var vm: CertificateItemViewModel?
        if viewModel.certificate.vaccinationCertificate.hcert.dgc.r != nil {
            vm = RecoveryCertificateItemViewModel(viewModel.certificate, active: true, neutral: true)
        }
        if viewModel.certificate.vaccinationCertificate.hcert.dgc.t != nil {
            vm = TestCertificateItemViewModel(viewModel.certificate, active: true, neutral: true)
        }
        if viewModel.certificate.vaccinationCertificate.hcert.dgc.v != nil {
            vm = VaccinationCertificateItemViewModel(viewModel.certificate, active: true, neutral: true)
        }
        if vm != nil {
            let item = CertificateItem(viewModel: vm!, action: {})
            view.addSubview(item)
            view.bottomConstraint.isActive = false
            view.topConstraint.constant = 24
            item.chevron.isHidden = true
            item.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                item.widthAnchor.constraint(equalTo: view.widthAnchor),
                item.topAnchor.constraint(equalTo: view.textLabel.bottomAnchor, constant: 16)
            ])
        }

        return view
    }()

    private lazy var footerView: UIView = {
        let footerView = UIView()
        footerView.frame.size.height = Constants.Layout.footerViewHeight

        let borderView = UIView()
        borderView.backgroundColor = .divider
        borderView.setConstant(height: 1)

        footerView.addSubview(borderView)
        footerView.addSubview(toolbar)
        footerView.addSubview(toolbarCancel)

        toolbar.delegate = self
        toolbar.state = .confirm("share_certificate_transmission_action_button_agree".localized)
        toolbar.primaryButton.isHidden = false

        toolbarCancel.delegate = self
        toolbarCancel.state = .confirm("share_certificate_action_button_cancel".localized)
        toolbarCancel.setUpLeftButton(leftButtonItem: .navigationArrow)
        toolbarCancel.primaryButton.isHidden = false

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbarCancel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([borderView.topAnchor.constraint(equalTo: footerView.topAnchor),
                                     borderView.widthAnchor.constraint(equalTo: footerView.widthAnchor),
                                     toolbar.topAnchor.constraint(equalTo: borderView.bottomAnchor, constant: .space_50),
                                     toolbar.widthAnchor.constraint(equalTo: footerView.widthAnchor),
                                     toolbar.heightAnchor.constraint(equalToConstant: Constants.Layout.mainButtonSize.height),
                                     toolbarCancel.topAnchor.constraint(equalTo: toolbar.bottomAnchor, constant: .space_24),
                                     toolbarCancel.widthAnchor.constraint(equalTo: footerView.widthAnchor),
                                     toolbarCancel.heightAnchor.constraint(equalToConstant: Constants.Layout.mainButtonSize.height)])
        return footerView
    }()

    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView(image: .chevronRight)
        imageView.tintColor = .onBackground100
        return imageView
    }()

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ConsentExchangeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self

        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ValidationServiceViewModel.Rows.additionalInformation.reuseIdentifier)
        tableView.register(HintTableViewCell.self, forCellReuseIdentifier: ValidationServiceViewModel.Rows.hintView.reuseIdentifier)
        tableView.register(SubTitleCell.self, forCellReuseIdentifier: ValidationServiceViewModel.Rows.provider.reuseIdentifier)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .divider
        tableView.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)

        updateView()

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorContainer.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorContainer.addSubview(activityIndicator)
        activityIndicator.topAnchor.constraint(equalTo: activityIndicatorContainer.topAnchor, constant: 40).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: activityIndicatorContainer.bottomAnchor, constant: -40.0).isActive = true
        activityIndicator.leftAnchor.constraint(equalTo: activityIndicatorContainer.leftAnchor, constant: 40.0).isActive = true
        activityIndicator.rightAnchor.constraint(equalTo: activityIndicatorContainer.rightAnchor, constant: -40.0).isActive = true
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

    func updateView() {
        tableView.reloadData()
        viewModel.isLoading ? toolbar.primaryButton.disable() : toolbar.primaryButton.enable()
    }

    @objc func cancel() {
        viewModel.cancel()
    }

    @objc func accept() {
        viewModel.routeToValidation()
    }
}

extension ConsentExchangeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == ValidationServiceViewModel.Rows.privacyLink.rawValue {
            viewModel.routeToPrivacyStatement()
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension ConsentExchangeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let reuseIdentifier = ValidationServiceViewModel.Rows(rawValue: indexPath.row)?.reuseIdentifier else {
            fatalError("There's something wrong with the tableview - we don't have a reuseidentifier")
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .none
        cell.accessoryView = nil
        cell.isUserInteractionEnabled = false

        activityIndicator.stopAnimating()
        guard !viewModel.isLoading else {
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = ""
            cell.detailTextLabel?.text = ""
            activityIndicatorContainer.removeFromSuperview()
            cell.contentView.addSubview(activityIndicatorContainer)
            activityIndicatorContainer.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
            activityIndicatorContainer.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            activityIndicator.startAnimating()
            return cell
        }

        switch indexPath.row {
        case ConsentExchangeViewModel.Rows.provider.rawValue:
            cell.textLabel?.attributedText = ConsentExchangeViewModel.Rows.provider.cellTitle
                .styledAs(.header_3)
            cell.detailTextLabel?.attributedText = viewModel.validationServiceName
                .styledAs(.body)
            cell.separatorInset = UIEdgeInsets.zero
        case ConsentExchangeViewModel.Rows.subject.rawValue:
            cell.textLabel?.attributedText = ConsentExchangeViewModel.Rows.subject.cellTitle
                .styledAs(.header_3)
            cell.detailTextLabel?.attributedText = viewModel.initialisationData.serviceProvider
                .styledAs(.body)
            cell.separatorInset = UIEdgeInsets.zero
        case ConsentExchangeViewModel.Rows.consentHeader.rawValue:
            cell.textLabel?.attributedText = "share_certificate_transmission_message".localized
                .styledAs(.body)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        case ConsentExchangeViewModel.Rows.hintView.rawValue:
            if let hintCell = cell as? HintTableViewCell {
                hintCell.titleText = ConsentExchangeViewModel.Rows.hintView.cellTitle
                    .styledAs(.header_3)
                hintCell.bodyText = viewModel.hintViewText
            }
        case ConsentExchangeViewModel.Rows.additionalInformation.rawValue:
            cell.textLabel?.attributedText = viewModel.additionalInformation
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        case ConsentExchangeViewModel.Rows.privacyLink.rawValue:
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

    func numberOfSections(in _: UITableView) -> Int {
        viewModel.numberOfSections
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        viewModel.isLoading ? 1 : viewModel.numberOfRows
    }
}

// MARK: - CustomToolbarViewDelegate

extension ConsentExchangeViewController: CustomToolbarViewDelegate {
    func customToolbarView(_ view: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .navigationArrow:
            navigationController?.popViewController(animated: true)
        case .cancelButton:
            cancel()
        case .textButton:
            if view == toolbar {
                viewModel.routeToValidation()
            } else {
                cancel()
            }
        default:
            return
        }
    }
}

// MARK: - ViewModelDelegate

extension ConsentExchangeViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        updateView()
    }

    func viewModelUpdateDidFailWithError(_: Error) {
        // already handled in ViewModel
    }
}
