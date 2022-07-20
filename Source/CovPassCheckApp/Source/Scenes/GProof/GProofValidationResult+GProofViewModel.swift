//
//  GProofValidationResult+GProofViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import UIKit

private enum Constants {
    static let footnoteSignal = "*"
    enum Keys {
        static let result_2G_certificate_invalid = "result_2G_certificate_invalid".localized
        static let result_2G_2nd_gproof_valid_recovery = "result_2G_2nd_recovery_valid".localized
        static let result_2G_2nd_gproof_valid_boosted = "result_2G_2nd_booster_valid".localized
        static let result_2G_2nd_gproof_valid_rapidtest = "result_2G_2nd_rapidtest_valid".localized
        static let result_2G_2nd_gproof_valid_pcrtest = "result_2G_2nd_pcrtest_valid".localized
        static let result_2G_2nd_empty = "result_2G_2nd_empty".localized
        static let result_2G_invalid_subtitle = "result_2G_invalid_subtitle".localized
        static let result_2G_empty_subtitle = "result_2G_empty_subtitle".localized
        static let result_2G_3rd_test_vacc_empty = "result_2G_3rd_test_vacc_empty".localized
        static let result_2G_3rd_test_recov_empty = "result_2G_3rd_test_recov_empty".localized
        static let result_2G_3rd_vacc_recov_empty = "result_2G_3rd_vacc_recov_empty".localized
        static let result_2G_2nd_gproof_valid_basic = "result_2G_2nd_basic_valid".localized
    }
    enum Images {
        static let detailStatusFull = UIImage.detailStatusFull
        static let detailStatusPartial = UIImage.detailStatusPartial
        static let detailStatusFailed = UIImage.detailStatusFailed
        static let detailStatusFullEmpty = UIImage.detailStatusFullEmpty
        static let detailStatusTestEmpty = UIImage.detailStatusTestEmpty
        static let detailStatusTest = UIImage.detailStatusTest
        static let chevronRight = UIImage.FieldRight
    }
}

public extension Optional where Wrapped == GProofValidationResult {
    
    func title(theOtherResultVM: GProofValidationResult?,
               initialTokenIsBoosted: Bool) -> String {
        if self?.error != nil {
            return Constants.Keys.result_2G_certificate_invalid
        }
        
        switch self?.token?.vaccinationCertificate.certType {
        case .vaccination:
            return vaccinationTitle(initialTokenIsBoosted: initialTokenIsBoosted)
        case .recovery:
            return Constants.Keys.result_2G_2nd_gproof_valid_recovery
        case .test:
            return self?.token?.vaccinationCertificate.hcert.dgc.isPCR ?? false ? Constants.Keys.result_2G_2nd_gproof_valid_pcrtest : Constants.Keys.result_2G_2nd_gproof_valid_rapidtest
        case .none:
            return theOtherResultVM.errorTitle
        }
    }
    
    func vaccinationTitle(initialTokenIsBoosted: Bool) -> String {
        guard let cert = self?.token?.vaccinationCertificate else {
            return Constants.Keys.result_2G_empty_subtitle
        }
        if initialTokenIsBoosted {
            return Constants.Keys.result_2G_2nd_gproof_valid_boosted
        } else if cert.hcert.dgc.isVaccinationBoosted && !cert.hcert.dgc.isJohnsonAndJohnson2of2Vaccination {
            return Constants.Keys.result_2G_2nd_gproof_valid_boosted
        } else if cert.hcert.dgc.v?.first?.fullImmunizationCheck ?? false {
            return Constants.Keys.result_2G_2nd_gproof_valid_basic
        } else {
            return Constants.Keys.result_2G_empty_subtitle
        }
    }
    
    var errorTitle: String {
        guard let certificate = self?.token?.vaccinationCertificate else {
            return Constants.Keys.result_2G_certificate_invalid
        }
        if certificate.isTest {
            return Constants.Keys.result_2G_3rd_vacc_recov_empty
        } else if certificate.isVaccination {
            return Constants.Keys.result_2G_3rd_test_recov_empty
        } else if certificate.isRecovery {
            if let openResults = self?.result?.openResults, openResults.count > 0 {
                return Constants.Keys.result_2G_2nd_gproof_valid_basic
            }
            return Constants.Keys.result_2G_3rd_test_vacc_empty
        } else {
            return Constants.Keys.result_2G_certificate_invalid
        }
    }
    
    var linkImage: UIImage? {
        if self?.error != nil {
            return Constants.Images.chevronRight
        }
        return nil
    }
    
    var subtitle: String? {
        if self?.error != nil {
            return Constants.Keys.result_2G_invalid_subtitle
        }
        switch self?.token?.vaccinationCertificate.certType {
        case .vaccination:
            return self?.token?.vaccinationCertificate.vaccinationSubtitle
        case .recovery:
            return self?.token?.vaccinationCertificate.recoverySubtitle
        case .test:
            return self?.token?.vaccinationCertificate.testSubtitle
        case .none:
            return Constants.Keys.result_2G_2nd_empty
        }
    }
    
    var image: UIImage {        
        if self?.error != nil {
            return Constants.Images.detailStatusFailed
        }
        if let openResults = self?.result?.openResults, openResults.count > 0 {
            return Constants.Images.detailStatusPartial
        }
        switch self?.token?.vaccinationCertificate.certType {
        case .vaccination, .recovery:
            return Constants.Images.detailStatusFull
        case .test:
            return Constants.Images.detailStatusTest
        case .none:
            return self?.token?.vaccinationCertificate.isTest ?? false ? Constants.Images.detailStatusTestEmpty : Constants.Images.detailStatusFullEmpty
        }
    }
}
