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
        title = "vaccination_detail_title".localized

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
            guard let self = self else { return }
            if self.viewModel.fullImmunization {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.router.presentPopup(onTopOf: self)
            }
        }
        stackView.setCustomSpacing(24, after: immunizationButtonContainerView)
    }

    private func setupPersonalData() {
        stackView.setCustomSpacing(12, after: personalDataHeadline)
        personalDataHeadline.attributedText = "vaccination_detail_personal_information".localized.styledAs(.header_2)
        personalDataHeadline.layoutMargins = .init(top: .space_30, left: .space_24, bottom: .zero, right: .space_24)

        nameView.attributedTitleText = "vaccination_detail_name".localized.styledAs(.header_3)
        nameView.attributedBodyText = viewModel?.name.styledAs(.body)
        nameView.contentView?.layoutMargins = .init(top: 12, left: 24, bottom: 12, right: 24)
        nameView.showBottomBorder()

        birtdateView.attributedTitleText = "vaccination_detail_birthdate".localized.styledAs(.header_3)
        birtdateView.attributedBodyText = viewModel?.birthDate.styledAs(.body)
        birtdateView.contentView?.layoutMargins = .init(top: 12, left: 24, bottom: 12, right: 24)
    }

    private func setupDeleteButton() {
        deleteButton.title = "vaccination_detail_delete".localized
        deleteButton.style = .secondary
        deleteButton.icon = .delete
        deleteButton.action = { [weak self] in
            let alertTitle = String(format: "vaccination_delete_title".localized, self?.viewModel.name ?? "")
            let alert = UIAlertController(title: alertTitle, message: "vaccination_delete_body".localized, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Abbrechen", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Löschen", style: .destructive, handler: { _ in
                self?.viewModel.delete().done({
                    self?.navigationController?.popViewController(animated: true)
                }).catch({ error in
                    print(error)
                    // TODO error handling
                })
            }))
            self?.present(alert, animated: true)
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

extension VaccinationDetailViewController: ScannerDelegate {
    public func result(with value: Result<String, ScanError>) {
        presentedViewController?.dismiss(animated: true, completion: nil)
        switch value {
        case .success(let payload):
            viewModel.process(payload: payload).done({ cert in
                self.setupView()
            }).catch({ error in
                print(error)
                // TODO error handling
            })
        case .failure(let error):
            print("We have an error: \(error)")
        }
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
