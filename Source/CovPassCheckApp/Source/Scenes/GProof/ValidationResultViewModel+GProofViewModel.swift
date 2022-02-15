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
        static let result_2G_gproof_invalid = "result_2G_gproof_invalid".localized
        static let result_2G_2nd_gproof_valid_recovery = "result_2G_2nd_recovery_valid".localized
        static let result_2G_2nd_gproof_valid_boosted = "result_2G_2nd_booster_valid".localized
        static let result_2G_2nd_gproof_valid_rapidtest = "result_2G_2nd_rapidtest_valid".localized
        static let result_2G_2nd_gproof_valid_pcrtest = "result_2G_2nd_pcrtest_valid".localized
        static let result_2G_2nd_empty = "result_2G_2nd_empty".localized
        static let result_2G_test_invalid = "result_2G_test_invalid".localized
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
        guard let certificate = self?.certificate else {
            return theOtherResultVM.errorTitle
        }
        switch self {
        case is ErrorResultViewModel:
            return certificate.isTest ? Constants.Keys.result_2G_test_invalid : Constants.Keys.result_2G_gproof_invalid
        case is RecoveryResultViewModel:
            return Constants.Keys.result_2G_2nd_gproof_valid_recovery
        case is VaccinationResultViewModel:
            if initialTokenIsBoosted {
                return Constants.Keys.result_2G_2nd_gproof_valid_boosted
            } else if certificate.isVaccination && certificate.hcert.dgc.isVaccinationBoosted {
                return Constants.Keys.result_2G_2nd_gproof_valid_boosted
            } else if certificate.isVaccination && certificate.hcert.dgc.isFullyImmunized {
                return Constants.Keys.result_2G_2nd_gproof_valid_basic
            } else {
                return Constants.Keys.result_2G_empty_subtitle
            }
        case  is TestResultViewModel:
            return certificate.hcert.dgc.isPCR ? Constants.Keys.result_2G_2nd_gproof_valid_pcrtest : Constants.Keys.result_2G_2nd_gproof_valid_rapidtest
        default:
            return theOtherResultVM.errorTitle
        }
    }
    
    var errorTitle: String {
        if self?.certificate?.isTest ?? false {
            return Constants.Keys.result_2G_3rd_vacc_recov_empty
        } else if self?.certificate?.isVaccination ?? false {
            return Constants.Keys.result_2G_3rd_test_recov_empty
        } else if self?.certificate?.isRecovery ?? false {
            return Constants.Keys.result_2G_3rd_test_vacc_empty
        } else {
            return Constants.Keys.result_2G_gproof_invalid
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
        guard let certificate = self?.certificate else {
            return Constants.Keys.result_2G_2nd_empty
        }
        switch self {
        case is ErrorResultViewModel:
            return certificate.isTest ? Constants.Keys.result_2G_invalid_subtitle : Constants.Keys.result_2G_invalid_subtitle
        case is RecoveryResultViewModel:
            return certificate.recoverySubtitle
        case is VaccinationResultViewModel:
            return certificate.vaccinationSubtitle
        case is TestResultViewModel:
            return certificate.testSubtitle
        default: return Constants.Keys.result_2G_2nd_empty
        }
    }
    
    var image: UIImage {
        switch self {
        case is ErrorResultViewModel: return Constants.Images.detailStatusFailed
        case is VaccinationResultViewModel, is RecoveryResultViewModel: return Constants.Images.detailStatusFull
        case is TestResultViewModel, is RecoveryResultViewModel: return Constants.Images.detailStatusTest
        default:
            return self?.certificate?.isTest ?? false ? Constants.Images.detailStatusTestEmpty : Constants.Images.detailStatusFullEmpty
        }
    }
}
