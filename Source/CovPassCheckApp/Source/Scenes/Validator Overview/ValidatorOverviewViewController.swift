//
//  ValidatorOverviewViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import Scanner
import UIKit

class ValidatorOverviewViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var moreButton: MainButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var informationIcon: UIImageView!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var informationTitle: PlainLabel!
    @IBOutlet var informationCopy: PlainLabel!
    @IBOutlet var checkTypesStackview: UIStackView!
    @IBOutlet var immunityCheckView: ImmunityScanCardView!
    @IBOutlet var timeHintContainerStackView: UIStackView!
    @IBOutlet var timeHintView: HintView!
    @IBOutlet var checkSituationContainerStackView: UIStackView!
    @IBOutlet var checkSituationView: ImageTitleSubtitleView!

    // MARK: - Properties

    private(set) var viewModel: ValidatorOverviewViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ValidatorOverviewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundPrimary
        viewModel.delegate = self
        setupHeaderView()
        setupCardView()
        setupCheckSituationView()
        viewModel.showNotificationsIfNeeded()
        scrollView.contentInsetAdjustmentBehavior = .never
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.updateTrustList()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Methods

    @IBAction func settingsTapped(_: Any) {
        viewModel.showAppInformation()
    }

    private func setupHeaderView() {
        moreButton.style = .alternativeWhiteBackground
        moreButton.title = viewModel.moreButtonTitle
        moreButton.action = viewModel.moreButtonTapped

        settingsButton.setImage(.settings, for: .normal)
        informationTitle.attributedText = viewModel.informationTitle.styledAs(.header_3)
        informationCopy.attributedText = viewModel.informationCopy.styledAs(.body)
        informationIcon.image = .warning
    }

    private func setupCardView() {
        setupTimeHintView()

        let immunityCheckTitleAccessibility = viewModel.immunityCheckTitleAccessibility
        let immunityCheckTitle = viewModel.immunityCheckTitle
            .styledAs(.header_2)
            .colored(.neutralWhite)
        let immunityCheckDescription = viewModel.immunityCheckDescription
            .styledAs(.body)
            .colored(.neutralWhite)
        let immunityCheckInfoText = viewModel.immunityCheckInfoText
            .styledAs(.header_3)
            .colored(.neutralWhite)
        let immunityCheckActionTitle = viewModel.immunityCheckActionTitle
        let descriptionTextBottomEdge = 4.0
        immunityCheckView.set(title: immunityCheckTitle,
                              titleAccessibility: immunityCheckTitleAccessibility,
                              titleEdges: .init(top: 24, left: 24, bottom: 8, right: 24),
                              description: immunityCheckDescription,
                              descriptionEdges: .init(top: 0, left: 19, bottom: descriptionTextBottomEdge, right: 19),
                              descriptionLinkColor: .white,
                              infoText: immunityCheckInfoText,
                              infoTextEdges: .init(top: 0, left: 0, bottom: 0, right: 0),
                              actionTitle: immunityCheckActionTitle)
        immunityCheckView.action = {
            self.viewModel.checkImmunityStatus()
        }

        immunityCheckView.linkAction = { _ in
            self.viewModel.routeToRulesUpdate()
        }
    }

    private func setupCheckSituationView() {
        let title = viewModel.checkSituationTitle.styledAs(.body).colored(.onBackground80)
        checkSituationView.update(title: title,
                                  leftImage: .flagDE,
                                  backGroundColor: .clear,
                                  imageWidth: .space_16,
                                  edgeInstes: .init(top: 0, left: 0, bottom: 0, right: 0))
        checkSituationContainerStackView.isHidden = false
    }

    private func setupTimeHintView() {
        timeHintContainerStackView.isHidden = viewModel.timeHintIsHidden
        timeHintView.iconView.image = viewModel.timeHintIcon
        timeHintView.iconLabel.text = ""
        timeHintView.iconLabel.isHidden = true
        timeHintView.titleLabel.attributedText = viewModel.timeHintTitle.styledAs(.header_3)
        timeHintView.bodyLabel.attributedText = viewModel.timeHintSubTitle.styledAs(.body)
        timeHintView.setConstraintsToEdge()
    }

    // MARK: - Actions

    @IBAction func routeToUpdateTapped(_: Any) {
        viewModel.routeToRulesUpdate()
    }
}

extension ValidatorOverviewViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        setupCardView()
        setupCheckSituationView()
    }

    func viewModelUpdateDidFailWithError(_: Error) {}
}
