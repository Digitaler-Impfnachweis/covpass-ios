//
//  DifferentPersonViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

private enum Constants {
    enum Keys {
        static let title = "infschg_result_mask_mandatory_deviating_data_title".localized
        static let subtitle = "infschg_result_mask_mandatory_deviating_data_copy".localized
        static let label_1stcert = "infschg_result_mask_mandatory_deviating_data_subtitle_1".localized
        static let label_2ndcert = "infschg_result_mask_mandatory_deviating_data_subtitle_2".localized
        static let label_3ndcert = "functional_validation_check_popup_second_scan_blue_card_3_title".localized
        static let ignore_title = "infschg_result_mask_mandatory_deviating_data_subtitle_3".localized
        static let ignore_copy = "infschg_result_mask_mandatory_deviating_data_copy_2".localized
        static let ignore_link = "infschg_result_mask_mandatory_deviating_data_link".localized
        static let rescanButtonTitle = "technical_validation_check_popup_retry".localized
        static let cancelButtonTitle = "technical_validation_check_popup_valid_vaccination_button_3_title".localized
        static let validation_check_popup_test_date_of_birth = "validation_check_popup_test_date_of_birth".localized
    }

    enum Images {
        static let iconCardInverse = UIImage.iconCardInverse
        static let iconCardInverseWarning = UIImage.iconCardInverseWarning
    }
}

struct PersonViewModel {
    let title: String
    let name: String
    let nameTranslittered: String
    let dateOfBirth: String
    let cardImage: UIImage
    let backgroundColor: UIColor
    let borderColor: UIColor
    let isHidden: Bool
}

class DifferentPersonViewModel: DifferentPersonViewModelProtocol {
    let title: String = Constants.Keys.title
    let subtitle: String = Constants.Keys.subtitle
    let footerHeadline: String = Constants.Keys.ignore_title
    let footerText: String = Constants.Keys.ignore_copy
    let footerLinkText: String = Constants.Keys.ignore_link
    let rescanButtonTitle: String = Constants.Keys.rescanButtonTitle
    let cancelButtonTitle: String = Constants.Keys.cancelButtonTitle
    var personViewModels: [PersonViewModel] = []
    var countdownTimerModel: CountdownTimerModel
    let ignoringIsHidden: Bool
    let thirdCardIsHidden: Bool
    var delegate: ViewModelDelegate? {
        didSet {
            countdownTimerModel.onUpdate = { [weak self] _ in
                self?.delegate?.viewModelDidUpdate()
            }
        }
    }

    private let tokens: [ExtendedCBORWebToken]
    private let resolver: Resolver<ValidatorDetailSceneResult>
    private let sameBirthdate: Bool

    init(tokens: [ExtendedCBORWebToken],
         resolver: Resolver<ValidatorDetailSceneResult>,
         countdownTimerModel: CountdownTimerModel) {
        self.tokens = tokens
        self.resolver = resolver
        self.countdownTimerModel = countdownTimerModel
        sameBirthdate = tokens.containsSameDob
        ignoringIsHidden = !sameBirthdate
        thirdCardIsHidden = tokens.count == 2
        let dateOfBirthFormat = Constants.Keys.validation_check_popup_test_date_of_birth
        for (index, token) in self.tokens.enumerated() {
            let dgc = token.vaccinationCertificate.hcert.dgc
            let dateOfBirthString = DateUtils.displayDateOfBirth(dgc)
            let dateOfBirth = String(format: dateOfBirthFormat, dateOfBirthString)
            let cardImage: UIImage
            let title: String
            let backgroundColor: UIColor
            let borderColor: UIColor
            let isHidden: Bool

            switch index {
            case 0:
                title = Constants.Keys.label_1stcert
                cardImage = Constants.Images.iconCardInverse
                backgroundColor = .brandAccent20
                borderColor = .clear
                isHidden = false
            case 1:
                title = Constants.Keys.label_2ndcert
                cardImage = thirdCardIsHidden ? Constants.Images.iconCardInverseWarning : Constants.Images.iconCardInverse
                backgroundColor = thirdCardIsHidden ? .resultYellowBackground : .brandAccent20
                borderColor = thirdCardIsHidden ? .resultYellow : .brandAccent20
                isHidden = false
            case 2:
                title = Constants.Keys.label_3ndcert
                cardImage = Constants.Images.iconCardInverseWarning
                backgroundColor = .resultYellowBackground
                borderColor = .resultYellow
                isHidden = thirdCardIsHidden
            default:
                title = Constants.Keys.label_1stcert
                cardImage = Constants.Images.iconCardInverse
                backgroundColor = .brandAccent20
                borderColor = .clear
                isHidden = false
            }

            let viewModel = PersonViewModel(title: title,
                                            name: dgc.nam.fullName,
                                            nameTranslittered: dgc.nam.fullNameTransliterated,
                                            dateOfBirth: dateOfBirth,
                                            cardImage: cardImage,
                                            backgroundColor: backgroundColor,
                                            borderColor: borderColor,
                                            isHidden: isHidden)
            personViewModels.append(viewModel)
        }
    }

    func rescan() {
        resolver.fulfill(.rescan)
    }

    func ignoreButton() {
        resolver.fulfill(.ignore)
    }

    func close() {
        resolver.fulfill(.close)
    }
}

private extension Array where Element == ExtendedCBORWebToken {
    var containsSameDob: Bool {
        let dobs = map(\.vaccinationCertificate.hcert.dgc.dob)
        return dobs.duplicates().count == 1
    }
}

private extension Array where Element == Date? {
    func duplicates() -> Array {
        let groups = Dictionary(grouping: self, by: { $0 })
        let duplicateGroups = groups.filter { $1.count > 1 }
        let duplicates = Array(duplicateGroups.keys)
        return duplicates
    }
}
