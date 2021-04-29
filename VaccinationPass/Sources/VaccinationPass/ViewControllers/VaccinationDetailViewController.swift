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
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var vaccinationsStackView: UIStackView!
    @IBOutlet var nameHeadline: PlainLabel!
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

        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back_arrow", in: UIConstants.bundle, compatibleWith: nil)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back_arrow", in: UIConstants.bundle, compatibleWith: nil)
        navigationController?.navigationBar.tintColor = UIConstants.BrandColor.onBackground100

        let favoriteIcon = UIBarButtonItem(image: UIImage(named: viewModel.isFavorite ? "star_full" : "star_partial", in: UIConstants.bundle, compatibleWith: nil), style: .plain, target: self, action: #selector(onFavorite))
        favoriteIcon.tintColor = UIConstants.BrandColor.onBackground100
        navigationItem.rightBarButtonItem = favoriteIcon
    }
    
    private func setupView() {
        view.backgroundColor = UIConstants.BrandColor.backgroundPrimary

        nameHeadline.attributedText = viewModel.name.toAttributedString(.h2)
        nameHeadline.layoutMargins = .init(top: .space_30, left: .space_24, bottom: .space_16, right: .space_24)
        stackView.setCustomSpacing(24, after: nameHeadline)

        immunizationView.image = viewModel.immunizationIcon
        immunizationView.attributedTitleText = viewModel.immunizationTitle.toAttributedString(.h5)
        immunizationView.attributedBodyText = viewModel.immunizationBody.toAttributedString(.body)
        stackView.setCustomSpacing(24, after: immunizationView)

        immunizationButton.title = viewModel.immunizationButton
        immunizationButton.backgroundColor = UIColor.white
        immunizationButton.action = { [weak self] in
            guard let self = self else { return }
            if self.viewModel.partialVaccination {
                self.router.presentPopup(onTopOf: self)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        stackView.setCustomSpacing(24, after: immunizationButtonContainerView)

        stackView.setCustomSpacing(12, after: personalDataHeadline)
        personalDataHeadline.attributedText = "vaccination_detail_personal_information".localized.toAttributedString(.h4)
        personalDataHeadline.layoutMargins = .init(top: .space_30, left: .space_24, bottom: .zero, right: .space_24)

        nameView.attributedTitleText = "vaccination_detail_name".localized.toAttributedString(.h5)
        nameView.attributedBodyText = viewModel?.name.toAttributedString(.body)
        nameView.contentView?.layoutMargins = .init(top: 12, left: 24, bottom: 12, right: 24)
        nameView.showBottomBorder()

        stackView.setCustomSpacing(24, after: birtdateView)

        birtdateView.attributedTitleText = "vaccination_detail_birthdate".localized.toAttributedString(.h5)
        birtdateView.attributedBodyText = viewModel?.birthDate.toAttributedString(.body)
        birtdateView.contentView?.layoutMargins = .init(top: 12, left: 24, bottom: 12, right: 24)

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

        showVaccinations()
    }

    private func showVaccinations() {
        stackView.setCustomSpacing(30, after: vaccinationsStackView)
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
