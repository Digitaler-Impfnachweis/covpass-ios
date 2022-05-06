//
//  GProofViewModel+ValidationResultModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

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
        static let detailStatusFailed = UIImage.detailStatusFailed
        static let detailStatusFullEmpty = UIImage.detailStatusFullEmpty
        static let detailStatusTestEmpty = UIImage.detailStatusTestEmpty
        static let detailStatusTest = UIImage.detailStatusTest
        static let chevronRight = UIImage.FieldRight
    }
}

public extension Optional where Wrapped == ValidationResultViewModel {
    
    func title(theOtherResultVM: ValidationResultViewModel?,
               initialTokenIsBoosted: Bool) -> String {
        switch self {
        case is ErrorResultViewModel:
            return Constants.Keys.result_2G_certificate_invalid
        case is RecoveryResultViewModel:
            return Constants.Keys.result_2G_2nd_gproof_valid_recovery
        case is VaccinationResultViewModel:
            return vaccinationTitle(initialTokenIsBoosted: initialTokenIsBoosted)
        case  is TestResultViewModel:
            return self?.certificate?.vaccinationCertificate.hcert.dgc.isPCR ?? false ? Constants.Keys.result_2G_2nd_gproof_valid_pcrtest : Constants.Keys.result_2G_2nd_gproof_valid_rapidtest
        default:
            return theOtherResultVM.errorTitle
        }
    }
    
    func vaccinationTitle(initialTokenIsBoosted: Bool) -> String {
        guard let cert = self?.certificate?.vaccinationCertificate else {
            return Constants.Keys.result_2G_empty_subtitle
        }
        if initialTokenIsBoosted {
            return Constants.Keys.result_2G_2nd_gproof_valid_boosted
        } else if cert.hcert.dgc.isVaccinationBoosted {
            return Constants.Keys.result_2G_2nd_gproof_valid_boosted
        } else if cert.hcert.dgc.v?.first?.fullImmunizationCheck ?? false {
            return Constants.Keys.result_2G_2nd_gproof_valid_basic
        } else {
            return Constants.Keys.result_2G_empty_subtitle
        }
    }
    
    var errorTitle: String {
        guard let certificate = self?.certificate?.vaccinationCertificate else {
            return Constants.Keys.result_2G_certificate_invalid
        }
        if certificate.isTest {
            return Constants.Keys.result_2G_3rd_vacc_recov_empty
        } else if certificate.isVaccination {
            return Constants.Keys.result_2G_3rd_test_recov_empty
        } else if certificate.isRecovery {
            return Constants.Keys.result_2G_3rd_test_vacc_empty
        } else {
            return Constants.Keys.result_2G_certificate_invalid
        }
    }
    
    var linkImage: UIImage? {
        switch self {
        case is ErrorResultViewModel: return Constants.Images.chevronRight
        case is VaccinationResultViewModel, is RecoveryResultViewModel: return nil
        case is TestResultViewModel: return nil
        default: return nil
        }
    }
    
    var subtitle: String? {
        switch self {
        case is ErrorResultViewModel:
            return Constants.Keys.result_2G_invalid_subtitle
        case is RecoveryResultViewModel:
            return self?.certificate?.vaccinationCertificate.recoverySubtitle
        case is VaccinationResultViewModel:
            return self?.certificate?.vaccinationCertificate.vaccinationSubtitle
        case is TestResultViewModel:
            return self?.certificate?.vaccinationCertificate.testSubtitle
        default:
            return Constants.Keys.result_2G_2nd_empty
        }
    }
    
    var image: UIImage {
        switch self {
        case is ErrorResultViewModel: return Constants.Images.detailStatusFailed
        case is VaccinationResultViewModel, is RecoveryResultViewModel: return Constants.Images.detailStatusFull
        case is TestResultViewModel, is RecoveryResultViewModel: return Constants.Images.detailStatusTest
        default:
            return self?.certificate?.vaccinationCertificate.isTest ?? false ? Constants.Images.detailStatusTestEmpty : Constants.Images.detailStatusFullEmpty
        }
    }
}
