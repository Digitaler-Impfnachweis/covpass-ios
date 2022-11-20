//
//  ValidatorOverviewViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import CovPassCommon
import Foundation
import Scanner
import UIKit

public enum CheckType: Int {
    case mask, immunity
}

class ValidatorOverviewViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var headerView: InfoHeaderView!
    @IBOutlet var scanCard: ScanCardView!
    @IBOutlet var checkTypesStackview: UIStackView!
    @IBOutlet var immunityCheckView: ImmunityScanCardView!
    @IBOutlet var checkTypeSegment: SegmentedControl!
    @IBOutlet var timeHintContainerStackView: UIStackView!
    @IBOutlet var timeHintView: HintView!
    @IBOutlet var offlineInformationView: UIView!
    @IBOutlet var offlineInformationStateWrapperView: UIView!
    @IBOutlet var offlineInformationTitleLabel: PlainLabel!
    @IBOutlet var offlineInformationStateImageView: UIImageView!
    @IBOutlet var offlineInformationStateTextLabel: PlainLabel!
    @IBOutlet var offlineInformationDescriptionLabel: PlainLabel!
    @IBOutlet var offlineInformationUpdateCellTitleLabel: PlainLabel!
    @IBOutlet var offlineInformationUpdateCellSubtitleLabel: PlainLabel!
    @IBOutlet var offlineInformationCellAccesoryImageView: UIImageView!
    @IBOutlet var offlineInformationUpdateContainer: UIView!
    @IBOutlet var offlineModusTopContainer: UIView!
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
        setupOfflineInformationView()
        setupCheckSituationView()
        viewModel.showNotificationsIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.updateTrustList()
        viewModel.updateDCCRules()
        viewModel.updateValueSets()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Methods

    private func setupHeaderView() {
        headerView.attributedTitleText = viewModel.title.styledAs(.header_2)
        let settingsImage: UIImage = .settings
        settingsImage.accessibilityLabel = "app_information_title".localized
        settingsImage.accessibilityTraits = .button
        headerView.image = settingsImage
        headerView.action = viewModel.showAppInformation
    }

    private func setScanButtonLoadingState() {
        if viewModel.isLoadingScan {
            scanCard.actionButton.startAnimating()
        } else {
            scanCard.actionButton.stopAnimating()
        }
    }
    
    private func setupCardView() {
        setScanButtonLoadingState()        
        setupTimeHintView()
        
        scanCard.actionButton.title = viewModel.scanActionTitle
        scanCard.actionButton.action = {
            self.viewModel.scanAction(additionalToken: nil)
        }
        scanCard.titleLabel.attributedText = viewModel.scanDropDownTitle
            .styledAs(.header_3)
            .colored(.neutralWhite)
        scanCard.textLabel.attributedText = viewModel.scanDropDownValue
            .styledAs(.body)
            .colored(.neutralWhite)
        scanCard.chooseAction = viewModel.chooseAction
        scanCard.chooseButton.innerButton.titleLabel?.text = nil
        scanCard.chooseButton.enableAccessibility(label: viewModel.scanDropDownTitle,
                                                          hint: viewModel.scanDropDownValue,
                                                          traits: .selected)
        
        let immunityCheckTitleAccessibility = viewModel.immunityCheckTitleAccessibility
        let immunityCheckTitle = viewModel.immunityCheckTitle
            .styledAs(.header_2)
            .colored(.neutralWhite)
        let immunityCheckDescription = viewModel.immunityCheckDescription
            .styledAs(.body)
            .colored(.neutralWhite)
        let immunityCheckInfoText = viewModel.immunityCheckInfoText?
            .styledAs(.header_3)
            .colored(.neutralWhite)
        let immunityCheckActionTitle = viewModel.immunityCheckActionTitle
        let descriptionTextBottomEdge = viewModel.immunityCheckInfoText == nil ? 24.0 : 12.0
        immunityCheckView.set(title: immunityCheckTitle,
                              titleAccessibility: immunityCheckTitleAccessibility,
                              titleEdges: .init(top: 24, left: 24, bottom: 8, right: 24),
                              description: immunityCheckDescription,
                              descriptionEdges: .init(top: 8, left: 24, bottom: descriptionTextBottomEdge, right: 24),
                              infoText: immunityCheckInfoText,
                              infoTextEdges: .init(top: 0, left: 0, bottom: 0, right: 0),
                              actionTitle: immunityCheckActionTitle)
        immunityCheckView.action = {
            self.viewModel.checkImmunityStatus(secondToken: nil, thirdToken: nil)
        }
        
        configureSegmentControl()
    }
    
    func configureSegmentControl(){
        checkTypeSegment.setTitle(viewModel.segmentMaskTitle, forSegmentAt: CheckType.mask.rawValue)
        checkTypeSegment.setTitle(viewModel.segmentImmunityTitle, forSegmentAt: CheckType.immunity.rawValue)
        let font = UIFont(name: UIFont.sansBold, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0, weight: .bold)
        let boldTextAttributes: [NSAttributedString.Key : AnyObject] = [.font : font]
        checkTypeSegment.setTitleTextAttributes(boldTextAttributes, for: .selected)
        checkTypeSegment.selectedSegmentIndex = viewModel.selectedCheckType.rawValue
        immunityCheckView.isHidden = viewModel.selectedCheckType == .mask
        scanCard.isHidden = viewModel.selectedCheckType == .immunity
    }
    
    private func setupCheckSituationView() {
        let title = viewModel.checkSituationTitle.styledAs(.body).colored(.onBackground80)
        let image = viewModel.checkSituationImage
        checkSituationView.update(title: title,
                                  leftImage: image,
                                  backGroundColor: .clear,
                                  imageWidth: .space_16,
                                  edgeInstes: .init(top: 0, left: 0, bottom: 0, right: 0))
        checkSituationContainerStackView.isHidden = viewModel.selectedCheckType == .mask
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
    
    private func setupOfflineInformationView() {
        offlineInformationView.layer.cornerRadius = 8
        offlineInformationTitleLabel.attributedText = viewModel.offlineInformationTitle.styledAs(.header_3)
        offlineInformationStateImageView.image = viewModel.offlineInformationStateIcon
        offlineInformationStateWrapperView.backgroundColor = viewModel.offlineInformationStateBackgroundColor
        offlineInformationStateWrapperView.layer.cornerRadius = 12
        offlineInformationStateImageView.image = viewModel.offlineInformationStateIcon
        offlineInformationStateTextLabel.attributedText  = viewModel.offlineInformationStateText.styledAs(.label).colored(viewModel.offlineInformationStateTextColor)
        offlineInformationDescriptionLabel.attributedText = viewModel.offlineInformationDescription.styledAs(.body)
        offlineInformationUpdateCellTitleLabel.attributedText = viewModel.offlineInformationUpdateCellTitle.styledAs(.header_3)
        offlineInformationUpdateCellSubtitleLabel.attributedText = viewModel.offlineInformationUpdateCellSubtitle.styledAs(.body)
        offlineInformationCellAccesoryImageView.image = viewModel.offlineInformationCellIcon
        offlineInformationUpdateContainer.enableAccessibility(label: viewModel.offlineInformationUpdateCellTitle,
                                                              hint: viewModel.offlineInformationUpdateCellSubtitle,
                                                              traits: .button)
        let offlineInformationAccessibilityText = viewModel.offlineInformationTitle + " " + viewModel.offlineInformationStateText
        offlineModusTopContainer.enableAccessibility(label: offlineInformationAccessibilityText,
                                                     hint: viewModel.offlineInformationDescription,
                                                     traits: .staticText)
    }

    // MARK: - Actions

    @IBAction func chekTypeSegmentChanged(_ sender: UISegmentedControl) {
        guard let selectedCheckType = CheckType(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        viewModel.selectedCheckType = selectedCheckType
    }
    
    @IBAction func routeToUpdateTapped(_ sender: Any) {
         viewModel.routeToRulesUpdate()
     }
}

extension ValidatorOverviewViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        setupCardView()
        setupOfflineInformationView()
        setupCheckSituationView()
    }

    func viewModelUpdateDidFailWithError(_: Error) {}
}
