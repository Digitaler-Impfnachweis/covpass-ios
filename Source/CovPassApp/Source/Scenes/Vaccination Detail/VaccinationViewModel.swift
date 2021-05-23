//
//  VaccinationViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon
import CovPassUI
import PromiseKit

struct VaccinationViewModel {
    // MARK: - Properties

    private let vaccination: Vaccination
    private weak var delegate: VaccinationViewDelegate?

    var headline: String {
        let number = vaccination.dn
        let total = vaccination.sd
        return String(format: "vaccination_certificate_detail_view_vaccination_title".localized, number, total)
    }

    var date: String {
        DateUtils.displayDateFormatter.string(from: vaccination.dt)
    }

    var vaccine: String {
        vaccination.map(key: vaccination.mp, from: Bundle.commonBundle.url(forResource: "vaccine-medicinal-product", withExtension: "json")) ?? vaccination.mp
    }

    var manufacturer: String {
        vaccination.map(key: vaccination.ma, from: Bundle.commonBundle.url(forResource: "vaccine-mah-manf", withExtension: "json")) ?? vaccination.ma
    }

    var vaccineCode: String {
        vaccination.map(key: vaccination.vp, from: Bundle.commonBundle.url(forResource: "vaccine-prophylaxis", withExtension: "json")) ?? vaccination.vp
    }

    var fullVaccineProduct: String {
        "\(vaccineCode)(\(vaccine))"
    }

    var issuer: String {
        vaccination.is
    }

    var country: String {
        vaccination.map(key: vaccination.co, from: Bundle.commonBundle.url(forResource: "country", withExtension: "json")) ?? vaccination.co
    }

    var uvci: String {
        vaccination.ci
    }

    // MARK: - Lifecycle

    init(
        vaccination: Vaccination,
        delegate: VaccinationViewDelegate?
    ) {
        self.vaccination = vaccination
        self.delegate = delegate
    }

    func delete() {
<<<<<<< HEAD
        guard let vaccination = token.vaccinationCertificate.hcert.dgc.v.first else { return }
        self.delegate?.didPressDelete(vaccination).then {
            self.repository.getVaccinationCertificateList()
        }.then { list -> Promise<VaccinationCertificateList> in
            var certList = list
            certList.certificates.removeAll(where: { cert in
                if cert.vaccinationCertificate.hcert.dgc.v.first?.ci == self.vaccination?.ci {
                    return true
                }
                return false
            })
            return Promise.value(certList)
        }
        .then { list -> Promise<VaccinationCertificateList> in
            self.repository.saveVaccinationCertificateList(list)
        }.done { list in
            let certList = list.certificates.filter { $0.vaccinationCertificate.hcert.dgc == self.token.hcert.dgc }
            self.delegate?.didUpdateCertificates(certList)
        }.catch { error in
            self.delegate?.updateDidFailWithError(error)
        }
=======
        delegate?.vaccinationViewDidPressDelete(vaccination)
>>>>>>> 196ee5a3... Clean up viewmodels for VaccinationDetail scene and solve a Memory Leak
    }
    
    func showCertificate() {
        delegate?.vaccinationViewDidPressShowQRCode(vaccination)
    }
}
