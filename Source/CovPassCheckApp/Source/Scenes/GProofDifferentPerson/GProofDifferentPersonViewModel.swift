//
//  GProofDifferentPersonViewModel.swift
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
        static let warning_2G_names_title = "warning_2G_names_title".localized
        static let warning_2G_names_subtitle = "warning_2G_names_subtitle".localized
        static let warning_2G_names_label_1stcert = "warning_2G_names_label_1stcert".localized
        static let warning_2G_names_label_2ndcert = "warning_2G_names_label_2ndcert".localized
        static let warning_2G_names_ignore_title = "warning_2G_names_ignore_title".localized
        static let warning_2G_names_ignore_copy = "warning_2G_names_ignore_copy".localized
        static let warning_2G_names_ignore_link = "warning_2G_names_ignore_link".localized
        static let result_2G_button_retry = "result_2G_button_retry".localized
        static let result_2G_button_startover = "result_2G_button_startover".localized
        static let validation_check_popup_test_date_of_birth = "validation_check_popup_test_date_of_birth".localized
    }
    enum Images {
        static let iconCardInverse = UIImage.iconCardInverse
        static let iconCardInverseWarning = UIImage.iconCardInverseWarning
    }
}

class GProofDifferentPersonViewModel: GProofDifferentPersonViewModelProtocol {

    var title: String { Constants.Keys.warning_2G_names_title }
    var subtitle: String { Constants.Keys.warning_2G_names_subtitle }
    var firstResultCardImage: UIImage { Constants.Images.iconCardInverse }
    var SecondResultCardImage: UIImage { Constants.Images.iconCardInverseWarning }
    var firstResultTitle: String { Constants.Keys.warning_2G_names_label_1stcert }
    var secondResultTitle: String { Constants.Keys.warning_2G_names_label_2ndcert }
    var footerHeadline: String { Constants.Keys.warning_2G_names_ignore_title }
    var footerText: String { Constants.Keys.warning_2G_names_ignore_copy }
    var footerLinkText: String { Constants.Keys.warning_2G_names_ignore_link }
    var retryButton: String { Constants.Keys.result_2G_button_retry }
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
    var delegate: ViewModelDelegate?
    var isDateOfBirthDifferent: Bool {
        return firstResultCert.hcert.dgc.dob != secondResultCert.hcert.dgc.dob
    }
    private var resolver: Resolver<GProofResult>
    
    init(firstResultCert: CBORWebToken,
         secondResultCert: CBORWebToken,
         resolver: Resolver<GProofResult>) {
        self.firstResultCert = firstResultCert
        self.secondResultCert = secondResultCert
        self.resolver = resolver
    }
    
    func startover() {
        resolver.fulfill(.startover)
    }
    
    func retry() {
        resolver.fulfill(.retry)
    }
    
    func cancel() {
        resolver.fulfill(.cancel)
    }
}
