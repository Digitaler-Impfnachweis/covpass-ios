//
//  VaccinationRepositoryMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit

public class VaccinationRepositoryMock: VaccinationRepositoryProtocol {
    
    var lastUpdatedTrustList: Date?
    var certificates: [ExtendedCBORWebToken] = []
    var certPair: [CertificatePair] = []

    public func matchedCertificates(for certificateList: CertificateList) -> [CertificatePair] {
        var pairs = [CertificatePair]()
        for cert in certificateList.certificates {
            var exists = false
            let isFavorite = certificateList.favoriteCertificateId == cert.vaccinationCertificate.hcert.dgc.uvci
            for index in 0 ..< pairs.count {
                if pairs[index].certificates.contains(where: {
                    cert.vaccinationCertificate.hcert.dgc.nam == $0.vaccinationCertificate.hcert.dgc.nam && cert.vaccinationCertificate.hcert.dgc.dob == $0.vaccinationCertificate.hcert.dgc.dob
                }) {
                    exists = true
                    pairs[index].certificates.append(cert)
                    if isFavorite {
                        pairs[index].isFavorite = true
                    }
                }
            }
            if !exists {
                pairs.append(CertificatePair(certificates: [cert], isFavorite: isFavorite))
            }
        }
        return pairs
    }

    public func getLastUpdatedTrustList() -> Date? {
        lastUpdatedTrustList
    }
    
    public func updateTrustListIfNeeded() -> Promise<Void> {
        Promise.value
    }

    public func updateTrustList() -> Promise<Void> {
        Promise.value
    }

    public func getCertificateList() -> Promise<CertificateList> {
        let certList = CertificateList(certificates: certificates)
        return Promise.value(certList)
    }

    public func saveCertificateList(_: CertificateList) -> Promise<CertificateList> {
        Promise.value(CertificateList(certificates: []))
    }

    public func delete(_: ExtendedCBORWebToken) -> Promise<Void> {
        .value
    }

    var favoriteToggle = false
    public func toggleFavoriteStateForCertificateWithIdentifier(_: String) -> Promise<Bool> {
        favoriteToggle.toggle()
        return .value(favoriteToggle)
    }

    public func setExpiryAlert(shown _: Bool, token _: ExtendedCBORWebToken) -> Promise<Void> {
        Promise.value
    }

    public func favoriteStateForCertificates(_: [ExtendedCBORWebToken]) -> Promise<Bool> {
        .value(favoriteToggle)
    }

    public func scanCertificate(_: String) -> Promise<ExtendedCBORWebToken> {
        return Promise { seal in
            seal.reject(ApplicationError.unknownError)
        }
    }

    public func checkCertificate(_: String) -> Promise<CBORWebToken> {
        return Promise { seal in
            seal.reject(ApplicationError.unknownError)
        }
    }
}

