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
    var certItem: CertificateItem {
            var vm: CertificateItemViewModel?
            if vaccinationCertificate.hcert.dgc.r != nil {
                vm = RecoveryCertificateItemViewModel(self, active: true, neutral: true)
            }
            if vaccinationCertificate.hcert.dgc.t != nil {
                vm = TestCertificateItemViewModel(self, active: true, neutral: true)
            }
            if vaccinationCertificate.hcert.dgc.v != nil {
                vm = VaccinationCertificateItemViewModel(self, active: true, neutral: true)
            }
            let certItem: CertificateItem = CertificateItem(viewModel: vm!, action: {
                // Action on Cert Tap
            })
            certItem.chevron.isHidden = true
            return certItem
    }
}
