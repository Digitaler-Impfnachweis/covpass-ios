//
//  ExtendedCBORWebToken+ReissueResultViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon
import CovPassUI

extension ExtendedCBORWebToken {
    func certItem(active: Bool) -> CertificateItem {
            var vm: CertificateItemViewModel?
            if vaccinationCertificate.hcert.dgc.r != nil {
                vm = RecoveryCertificateItemViewModel(self, active: active, neutral: true)
            }
            if vaccinationCertificate.hcert.dgc.t != nil {
                vm = TestCertificateItemViewModel(self, active: active, neutral: true)
            }
            if vaccinationCertificate.hcert.dgc.v != nil {
                vm = VaccinationCertificateItemViewModel(self, active: active, neutral: true)
            }
            let certItem: CertificateItem = CertificateItem(viewModel: vm!)
            certItem.chevron.isHidden = true
            return certItem
    }
}
