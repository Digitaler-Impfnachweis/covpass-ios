//
//  VaccinationDetailViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import VaccinationUI
import UIKit
import VaccinationCommon
import Scanner

public class VaccinationDetailViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var vaccinationsStackView: UIStackView!
    @IBOutlet var nameHeadline: PlainLabel!
    @IBOutlet var immunizationContainerView: UIView!
    @IBOutlet var immunizationView: ParagraphView!
    @IBOutlet var immunizationButtonContainerView: UIStackView!
    @IBOutlet var immunizationButton: MainButton!
    @IBOutlet var personalDataHeadline: PlainLabel!
    @IBOutlet var nameView: ParagraphView!
    @IBOutlet var birtdateView: ParagraphView!
    @IBOutlet var deleteButton: MainButton!
    
    public var viewModel: VaccinationDetailViewModel!
    public var router: PopupRouter!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
    }

    private func setupNavigationBar() {
        title = "vaccination_certificate_detail_view_title".localized

        navigationController?.navigationBar.backIndicatorImage = .arrowBack
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = .arrowBack
        navigationController?.navigationBar.tintColor = .onBackground100

        let favoriteIcon = UIBarButtonItem(image: viewModel.isFavorite ? .starFull : .starPartial, style: .plain, target: self, action: #selector(onFavorite))
        favoriteIcon.tintColor = .onBackground100
        navigationItem.rightBarButtonItem = favoriteIcon
    }

    private func setupView() {
        view.backgroundColor = .backgroundPrimary
        scrollView.contentInset = .init(top: .space_24, left: .zero, bottom: .space_70, right: .zero)

        setupHeadline()
        setupImmunizationView()
        setupPersonalData()
        setupDeleteButton()
        setupVaccinations()
    }

    private func setupHeadline() {
        nameHeadline.attributedText = viewModel.name.styledAs(.header_1).colored(.onBackground100)
        nameHeadline.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
        stackView.setCustomSpacing(.space_24, after: nameHeadline)
    }
    
    private func setupImmunizationView() {
        immunizationContainerView.layoutMargins.top = .space_24
        immunizationContainerView.layoutMargins.bottom = .space_24
        immunizationContainerView.backgroundColor = .neutralWhite
        immunizationView.stackView.alignment = .top
        immunizationView.image = viewModel.immunizationIcon
        immunizationView.attributedTitleText = viewModel.immunizationTitle.styledAs(.header_3)
        immunizationView.attributedBodyText = viewModel.immunizationBody.styledAs(.body).colored(.onBackground70)
        immunizationView.layoutMargins.bottom = .space_24

        immunizationButton.title = viewModel.immunizationButton
        immunizationButton.backgroundColor = UIColor.white

        immunizationButton.action = { [weak self] in
            self?.viewModel.immunizationButtonTapped()
        }
        stackView.setCustomSpacing(.space_24, after: immunizationButtonContainerView)
    }

    private func setupPersonalData() {
        stackView.setCustomSpacing(.space_12, after: personalDataHeadline)
        personalDataHeadline.attributedText = "vaccination_certificate_detail_view_personal_data_title".localized.styledAs(.header_2)
        personalDataHeadline.layoutMargins = .init(top: .space_30, left: .space_24, bottom: .zero, right: .space_24)

        nameView.attributedTitleText = "vaccination_certificate_detail_view_name".localized.styledAs(.header_3)
        nameView.attributedBodyText = viewModel?.name.styledAs(.body)
        nameView.contentView?.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .space_12, right: .space_24)
        nameView.showBottomBorder()

        birtdateView.attributedTitleText = "vaccination_certificate_detail_view_birthdate".localized.styledAs(.header_3)
        birtdateView.attributedBodyText = viewModel?.birthDate.styledAs(.body)
        birtdateView.contentView?.layoutMargins = .init(top: .space_12, left: .space_24, bottom: .space_12, right: .space_24)
    }

    private func setupDeleteButton() {
        deleteButton.title = "vaccination_certificate_detail_view_delete_button_title".localized
        deleteButton.style = .secondary
        deleteButton.icon = .delete
        deleteButton.action = { [weak self] in
            self?.viewModel.delete()
        }
    }

    private func setupVaccinations() {
        stackView.setCustomSpacing(.space_40, after: vaccinationsStackView)
        vaccinationsStackView.subviews.forEach {
            $0.removeFromSuperview()
            self.vaccinationsStackView.removeArrangedSubview($0)
        }
        viewModel.vaccinations.forEach({
            vaccinationsStackView.addArrangedSubview(VaccinationView(viewModel: $0))
        })
    }

    @objc public func onFavorite() {
        viewModel.updateFavorite().done({
            self.setupNavigationBar()
        }).catch({ error in
            print(error)
        })
    }
}

extension VaccinationDetailViewController: StoryboardInstantiating {
    public static var bundle: Bundle {
        return Bundle.module
    }
    public static var storyboardName: String {
        VaccinationPassConstants.Storyboard.Pass
    }
}
