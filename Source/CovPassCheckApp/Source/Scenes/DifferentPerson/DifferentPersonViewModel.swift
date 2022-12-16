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

class DifferentPersonViewModel: DifferentPersonViewModelProtocol {
    let title: String = Constants.Keys.title
    let subtitle: String = Constants.Keys.subtitle
    let firstResultTitle: String = Constants.Keys.label_1stcert
    let firstResultCardImage: UIImage = Constants.Images.iconCardInverse
    let footerHeadline: String = Constants.Keys.ignore_title
    let footerText: String = Constants.Keys.ignore_copy
    let footerLinkText: String = Constants.Keys.ignore_link
    let rescanButtonTitle: String = Constants.Keys.rescanButtonTitle
    let cancelButtonTitle: String = Constants.Keys.cancelButtonTitle
    let firstResultName: String
    let firstResultNameTranslittered: String
    let firstResultDateOfBirth: String
    let secondResultTitle: String = Constants.Keys.label_2ndcert
    let secondResultName: String
    let secondResultNameTranslittered: String
    let secondResultCardImage: UIImage
    let secondResultDateOfBirth: String
    let thirdResultTitle: String = Constants.Keys.label_3ndcert
    let thirdResultCardImage: UIImage = Constants.Images.iconCardInverseWarning
    let thirdResultName: String?
    let thirdResultNameTranslittered: String?
    let thirdResultDateOfBirth: String?
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

    private let firstToken: ExtendedCBORWebToken
    private let secondToken: ExtendedCBORWebToken
    private let thirdToken: ExtendedCBORWebToken?
    private let resolver: Resolver<ValidatorDetailSceneResult>
    private let sameBirthdate: Bool
    private let isThirdScan: Bool

    init(firstToken: ExtendedCBORWebToken,
         secondToken: ExtendedCBORWebToken,
         thirdToken: ExtendedCBORWebToken?,
         resolver: Resolver<ValidatorDetailSceneResult>,
         countdownTimerModel: CountdownTimerModel) {
        self.firstToken = firstToken
        self.secondToken = secondToken
        self.thirdToken = thirdToken
        self.resolver = resolver
        self.countdownTimerModel = countdownTimerModel
        let firstAndSecondTokenSameDate = firstToken.vaccinationCertificate.hcert.dgc.dob == secondToken.vaccinationCertificate.hcert.dgc.dob
        var secondAndThirdTokenSameDat = true
        if let thirdToken = thirdToken {
            secondAndThirdTokenSameDat = secondToken.vaccinationCertificate.hcert.dgc.dob == thirdToken.vaccinationCertificate.hcert.dgc.dob
        }
        sameBirthdate = firstAndSecondTokenSameDate && secondAndThirdTokenSameDat
        ignoringIsHidden = !sameBirthdate
        isThirdScan = thirdToken != nil
        thirdCardIsHidden = thirdToken == nil
        let firstTokenDgc = firstToken.vaccinationCertificate.hcert.dgc
        firstResultName = firstTokenDgc.nam.fullName
        firstResultNameTranslittered = firstTokenDgc.nam.fullNameTransliterated
        firstResultDateOfBirth = String(format: Constants.Keys.validation_check_popup_test_date_of_birth,
                                        DateUtils.displayDateOfBirth(firstTokenDgc))
        let secondTokenDgc = secondToken.vaccinationCertificate.hcert.dgc
        secondResultName = secondTokenDgc.nam.fullName
        secondResultNameTranslittered = secondTokenDgc.nam.fullNameTransliterated
        secondResultCardImage = thirdCardIsHidden ? Constants.Images.iconCardInverseWarning : Constants.Images.iconCardInverse
        secondResultDateOfBirth = String(format: Constants.Keys.validation_check_popup_test_date_of_birth,
                                         DateUtils.displayDateOfBirth(secondTokenDgc))
        let thirdTokenDgc = thirdToken?.vaccinationCertificate.hcert.dgc
        thirdResultName = thirdTokenDgc?.nam.fullName
        thirdResultNameTranslittered = thirdTokenDgc?.nam.fullNameTransliterated
        if let dgc = thirdTokenDgc {
            thirdResultDateOfBirth = String(format: Constants.Keys.validation_check_popup_test_date_of_birth,
                                            DateUtils.displayDateOfBirth(dgc))
        } else {
            thirdResultDateOfBirth = nil
        }
    }

    func rescan() {
        if isThirdScan {
            resolver.fulfill(.thirdScan(firstToken, secondToken))
        } else {
            resolver.fulfill(.secondScan(firstToken))
        }
    }

    func ignoreButton() {
        resolver.fulfill(.ignore(firstToken, secondToken, thirdToken))
    }

    func close() {
        resolver.fulfill(.close)
    }
}
