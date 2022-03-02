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
import XCTest

public class VaccinationRepositoryMock: VaccinationRepositoryProtocol {

    let getCertificateListExpectation = XCTestExpectation(description: "getCertificateListExpectation")
    let setExpiryAlertExpectation = XCTestExpectation(description: "setExpiryAlertExpectation")
    let setReissueAlreadySeen = XCTestExpectation(description: "setReissueAlreadySeen")
    var lastUpdatedTrustList: Date?
    var certificates: [ExtendedCBORWebToken] = []
    var certPair: [CertificatePair] = []
    var shouldTrustListUpdate: Bool = true
    var deleteError: Error?
    
    public func matchedCertificates(for certificateList: CertificateList) -> [CertificatePair] {
        var pairs = [CertificatePair]()
        for cert in certificateList.certificates {
            var exists = false
            let isFavorite = certificateList.favoriteCertificateId == cert.vaccinationCertificate.hcert.dgc.uvci
            for index in 0 ..< pairs.count {
                let certDgc = cert.vaccinationCertificate.hcert.dgc
                if pairs[index].certificates.map(\.vaccinationCertificate.hcert.dgc).contains(certDgc) {
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
    
    public func trustListShouldBeUpdated() -> Promise<Bool> {
        .value(trustListShouldBeUpdated())
    }
    
    public func trustListShouldBeUpdated() -> Bool {
        shouldTrustListUpdate
    }
    
    public func updateTrustListIfNeeded() -> Promise<Void> {
        Promise.value
    }

    public func updateTrustList() -> Promise<Void> {
        Promise.value
    }

    public func getCertificateList() -> Promise<CertificateList> {
        getCertificateListExpectation.fulfill()
        let certList = CertificateList(certificates: certificates)
        return Promise.value(certList)
    }

    public func saveCertificateList(_: CertificateList) -> Promise<CertificateList> {
        Promise.value(CertificateList(certificates: []))
    }

    public func delete(_: ExtendedCBORWebToken) -> Promise<Void> {
        if let error = deleteError {
            return .init(error: error)
        }
        return .value
    }

    var favoriteToggle = false
    public func toggleFavoriteStateForCertificateWithIdentifier(_: String) -> Promise<Bool> {
        favoriteToggle.toggle()
        return .value(favoriteToggle)
    }

    var setExpiryAlertValue: (shown: Bool, token: ExtendedCBORWebToken)?
    public func setExpiryAlert(shown: Bool, token : ExtendedCBORWebToken) -> Promise<Void> {
        setExpiryAlertValue = (shown, token)
        setExpiryAlertExpectation.fulfill()
        return Promise.value
    }
    
    public func setReissueProcess(initialAlreadySeen: Bool,
                                  newBadgeAlreadySeen: Bool,
                                  tokens: [ExtendedCBORWebToken]) -> Promise<Void> {
        setReissueAlreadySeen.fulfill()
        return .value
    }

    public func favoriteStateForCertificates(_: [ExtendedCBORWebToken]) -> Promise<Bool> {
        .value(favoriteToggle)
    }

    public func scanCertificate(_: String, isCountRuleEnabled: Bool) -> Promise<QRCodeScanable> {
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

