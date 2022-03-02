//
//  VaccinationRepositoryMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import Foundation

public class VaccinationRepositoryMock: VaccinationRepositoryProtocol {
    var lastUpdateTrustList: Date?
    var shouldTrustListUpdate: Bool = false

    public func trustListShouldBeUpdated() -> Bool {
        shouldTrustListUpdate
    }

    public func updateTrustListIfNeeded() -> Promise<Void> {
        Promise.value
    }
    
    public func matchedCertificates(for _: CertificateList) -> [CertificatePair] {
        []
    }
    
    public func trustListShouldBeUpdated() -> Promise<Bool> {
        .value(trustListShouldBeUpdated())
    }
    
    public func getLastUpdatedTrustList() -> Date? {
        lastUpdateTrustList
    }
    
    var didUpdateTrustListHandler: (()->Void)?
    
    public func updateTrustList() -> Promise<Void> {
        didUpdateTrustListHandler?()
        return Promise.value
    }

    public func getCertificateList() -> Promise<CertificateList> {
        Promise.value(CertificateList(certificates: []))
    }

    public func saveCertificateList(_: CertificateList) -> Promise<CertificateList> {
        Promise.value(CertificateList(certificates: []))
    }

    public func add(tokens: [ExtendedCBORWebToken]) -> Promise<Void> {
        .value
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
    
    public func setReissueProcess(initialAlreadySeen: Bool,
                                   newBadgeAlreadySeen: Bool,
                                   tokens: [ExtendedCBORWebToken]) -> Promise<Void> {
         return .value
     }

    public func favoriteStateForCertificates(_: [ExtendedCBORWebToken]) -> Promise<Bool> {
        .value(favoriteToggle)
    }

    public func scanCertificate(_ data: String, isCountRuleEnabled: Bool) -> Promise<QRCodeScanable> {
        return Promise { seal in
            seal.reject(ApplicationError.unknownError)
        }
    }

    var checkedCert: CBORWebToken? = nil
    var checkedCertError: Error = ApplicationError.unknownError

    public func checkCertificate(_: String) -> Promise<CBORWebToken> {
        return Promise { seal in
            checkedCert != nil ? seal.fulfill(checkedCert!) : seal.reject(checkedCertError)
        }
    }
}
