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
    var gProofCardImage: UIImage { Constants.Images.iconCardInverse }
    var testProofCardImage: UIImage { Constants.Images.iconCardInverseWarning }
    var gProofTitle: String { Constants.Keys.warning_2G_names_label_1stcert }
    var testProofTitle: String { Constants.Keys.warning_2G_names_label_2ndcert }
    var footerHeadline: String { Constants.Keys.warning_2G_names_ignore_title }
    var footerText: String { Constants.Keys.warning_2G_names_ignore_copy }
    var footerLinkText: String { Constants.Keys.warning_2G_names_ignore_link }
    var retryButton: String { Constants.Keys.result_2G_button_retry }
    var startOverButton: String { Constants.Keys.result_2G_button_startover }
    var gProofName: String { gProofToken.hcert.dgc.nam.fullName }
    var gProofNameTranslittered: String { gProofToken.hcert.dgc.nam.fullNameTransliterated }
    var gProofDateOfBirth: String {
        return String(format: Constants.Keys.validation_check_popup_test_date_of_birth, DateUtils.displayDateOfBirth(gProofToken.hcert.dgc))
    }
    var testProofName: String { testProofToken.hcert.dgc.nam.fullName }
    var testProofNameTranslittered: String { testProofToken.hcert.dgc.nam.fullNameTransliterated }
    var testProofDateOfBirth: String {
        return String(format: Constants.Keys.validation_check_popup_test_date_of_birth, DateUtils.displayDateOfBirth(testProofToken.hcert.dgc))
    }
    var gProofToken: CBORWebToken
    var testProofToken: CBORWebToken
    var delegate: ViewModelDelegate?
    var isDateOfBirthDifferent: Bool {
        return gProofToken.hcert.dgc.dob != testProofToken.hcert.dgc.dob
    }
    private var resolver: Resolver<GProofResult>
    
    init(gProofToken: CBORWebToken,
         testProofToken: CBORWebToken,
         resolver: Resolver<GProofResult>) {
        self.gProofToken = gProofToken
        self.testProofToken = testProofToken
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
