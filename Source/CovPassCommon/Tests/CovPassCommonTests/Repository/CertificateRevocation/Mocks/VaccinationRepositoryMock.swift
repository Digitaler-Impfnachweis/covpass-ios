//
//  VaccinationRepositoryMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit
import XCTest

public class VaccinationRepositoryMock: VaccinationRepositoryProtocol {
    let saveCertExpectation = XCTestExpectation(description: "get certificate list has to be called")
    let updateExpectation = XCTestExpectation(description: "updateExpectation")
    var error: Error?
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

    var didUpdateTrustListHandler: (() -> Void)?

    public func updateTrustList() -> Promise<Void> {
        didUpdateTrustListHandler?()
        return Promise.value
    }

    var getCertificatesList: [ExtendedCBORWebToken] = []
    public func getCertificateList() -> Promise<CertificateList> {
        if let error = error {
            return .init(error: error)
        }
        return Promise.value(CertificateList(certificates: getCertificatesList))
    }

    public func saveCertificateList(_ certList: CertificateList) -> Promise<CertificateList> {
        saveCertExpectation.fulfill()
        return .value(certList)
    }

    public func add(tokens _: [ExtendedCBORWebToken]) -> Promise<Void> {
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

    public func setExpiryAlert(shown _: Bool, tokens _: [ExtendedCBORWebToken]) -> Promise<Void> {
        Promise.value
    }

    public func setReissueProcess(initialAlreadySeen _: Bool,
                                  newBadgeAlreadySeen _: Bool,
                                  tokens _: [ExtendedCBORWebToken]) -> Promise<Void> {
        .value
    }

    public func favoriteStateForCertificates(_: [ExtendedCBORWebToken]) -> Promise<Bool> {
        .value(favoriteToggle)
    }

    public func scanCertificate(_: String, isCountRuleEnabled _: Bool, expirationRuleIsActive _: Bool) -> Promise<QRCodeScanable> {
        Promise { seal in
            seal.reject(ApplicationError.unknownError)
        }
    }

    var checkedCert: CBORWebToken?
    var checkedCertError: Error = ApplicationError.unknownError

    public func checkCertificate(_: String, expirationRuleIsActive _: Bool, checkSealCertificate _: Bool) -> Promise<CBORWebToken> {
        Promise { seal in
            checkedCert != nil ? seal.fulfill(checkedCert!) : seal.reject(checkedCertError)
        }
    }

    public func validCertificate(_: String, expirationRuleIsActive _: Bool, checkSealCertificate _: Bool) -> Promise<ExtendedCBORWebToken> {
        checkedCert != nil ?
            .value(
                ExtendedCBORWebToken(
                    vaccinationCertificate: checkedCert!,
                    vaccinationQRCodeData: ""
                )
            ) :
            .init(error: checkedCertError)
    }

    public func replace(_: ExtendedCBORWebToken) -> Promise<Void> {
        .init()
    }

    public func update(_: [ExtendedCBORWebToken]) -> Promise<Void> {
        updateExpectation.fulfill()
        return .init()
    }
}
