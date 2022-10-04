//
//  DifferentPersonViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import CovPassCommon
import UIKit
import PromiseKit

private enum Constants {
    enum Keys {
        static let title = "infschg_result_mask_mandatory_deviating_data_title".localized
        static let subtitle = "infschg_result_mask_mandatory_deviating_data_copy".localized
        static let label_1stcert = "infschg_result_mask_mandatory_deviating_data_subtitle_1".localized
        static let label_2ndcert = "infschg_result_mask_mandatory_deviating_data_subtitle_2".localized
        static let ignore_title = "infschg_result_mask_mandatory_deviating_data_subtitle_3".localized
        static let ignore_copy = "infschg_result_mask_mandatory_deviating_data_copy_2".localized
        static let ignore_link = "infschg_result_mask_mandatory_deviating_data_link".localized
        static let result_2G_button_startover = "result_2G_button_startover".localized
        static let validation_check_popup_test_date_of_birth = "validation_check_popup_test_date_of_birth".localized
    }
    enum Images {
        static let iconCardInverse = UIImage.iconCardInverse
        static let iconCardInverseWarning = UIImage.iconCardInverseWarning
    }
}

class DifferentPersonViewModel: DifferentPersonViewModelProtocol {

    var title: String { Constants.Keys.title }
    var subtitle: String { Constants.Keys.subtitle }
    var firstResultCardImage: UIImage { Constants.Images.iconCardInverse }
    var SecondResultCardImage: UIImage { Constants.Images.iconCardInverseWarning }
    var firstResultTitle: String { Constants.Keys.label_1stcert }
    var secondResultTitle: String { Constants.Keys.label_2ndcert }
    var footerHeadline: String { Constants.Keys.ignore_title }
    var footerText: String { Constants.Keys.ignore_copy }
    var footerLinkText: String { Constants.Keys.ignore_link }
    var startOverButton: String { Constants.Keys.result_2G_button_startover }
    var firstResultName: String { firstResultCert.hcert.dgc.nam.fullName }
    var firstResultNameTranslittered: String { firstResultCert.hcert.dgc.nam.fullNameTransliterated }
    var firstResultDateOfBirth: String {
        return String(format: Constants.Keys.validation_check_popup_test_date_of_birth, DateUtils.displayDateOfBirth(firstResultCert.hcert.dgc))
    }
    var secondResultName: String { secondResultCert.hcert.dgc.nam.fullName }
    var secondResultNameTranslittered: String { secondResultCert.hcert.dgc.nam.fullNameTransliterated }
    var secondResultDateOfBirth: String {
        return String(format: Constants.Keys.validation_check_popup_test_date_of_birth, DateUtils.displayDateOfBirth(secondResultCert.hcert.dgc))
    }
    var firstResultCert: CBORWebToken
    var secondResultCert: CBORWebToken
    let countdownTimerModel: CountdownTimerModel
    var delegate: ViewModelDelegate? = nil {
        didSet {
            countdownTimerModel.onUpdate = { [weak self] _ in
                self?.delegate?.viewModelDidUpdate()
            }
        }
    }
    private var resolver: Resolver<DifferentPersonResult>
    
    init(firstResultCert: CBORWebToken,
         secondResultCert: CBORWebToken,
         resolver: Resolver<DifferentPersonResult>,
         countdownTimerModel: CountdownTimerModel
    ) {
        self.firstResultCert = firstResultCert
        self.secondResultCert = secondResultCert
        self.resolver = resolver
        self.countdownTimerModel = countdownTimerModel
        countdownTimerModel.start()
    }
    
    func startover() {
        resolver.fulfill(.startover)
    }

    func ignoreButton() {
        resolver.fulfill(.ignore)
    }
}
