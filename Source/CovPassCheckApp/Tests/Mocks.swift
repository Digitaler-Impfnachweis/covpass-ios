//
//  Mocks.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import XCTest
import CovPassUI
import PromiseKit
import CertLogic
import SwiftyJSON

struct SceneCoordinatorMock: SceneCoordinator {
    func asRoot(_ factory: SceneFactory) {
    }
}

struct ValidationResultRouterMock: ValidationResultRouterProtocol {

    func showStart() {}

    func scanQRCode() -> Promise<ScanResult> {
        .value(.success(""))
    }

    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
}


class DCCCertLogicMock: DCCCertLogicProtocol {
        
    var lastUpdateDccrRules: Date?
    
    var countries: [Country] {
        [Country("DE")]
    }

    func lastUpdatedDCCRules() -> Date? {
        lastUpdateDccrRules
    }

    var validationError: Error?
    var validateResult: [ValidationResult]?
    func validate(type _: DCCCertLogic.LogicType, countryCode _: String, validationClock _: Date, certificate _: CBORWebToken) throws -> [ValidationResult] {
        if let err = validationError {
            throw err
        }
        return validateResult ?? []
    }

    func updateRulesIfNeeded() -> Promise<Void> {
        Promise.value
    }
    
    var didUpdateRules: (()->Void)?

    func updateRules() -> Promise<Void> {
        didUpdateRules?()
        return Promise.value
    }
}


public class VaccinationRepositoryMock: VaccinationRepositoryProtocol {
    
    var lastUpdateTrustList: Date?

    public func updateTrustListIfNeeded() -> Promise<Void> {
        Promise.value
    }
    
    public func matchedCertificates(for _: CertificateList) -> [CertificatePair] {
        []
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

    public func scanCertificate(_ data: String, isCountRuleEnabled: Bool) -> Promise<QRCodeScanable> {
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


extension Rule {
    static var mock: Rule {
        Rule(
            identifier: "",
            type: "",
            version: "",
            schemaVersion: "",
            engine: "",
            engineVersion: "",
            certificateType: "",
            description: [],
            validFrom: "",
            validTo: "",
            affectedString: [],
            logic: JSON(""),
            countryCode: "DE"
        )
    }

    func setIdentifier(_ identifier: String) -> Rule {
        self.identifier = identifier
        return self
    }

    func setHash(_ hash: String) -> Rule {
        self.hash = hash
        return self
    }
}

class ViewModelDelegateMock: ViewModelDelegate {
    
    var didUpdate: (()->Void)?
    var didFail: ((Error)->Void)?

    func viewModelDidUpdate() {
        didUpdate?()
    }
    
    func viewModelUpdateDidFailWithError(_ error: Error) {
        didFail?(error)
    }
}
