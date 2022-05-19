//
//  ValidatorRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit

class ValidatorMockRouter: ValidatorOverviewRouterProtocol {

    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()

    func showAppInformation(userDefaults: Persistence) {
        
    }
    
    func showCheckSituation(userDefaults: Persistence) -> Promise<Void> {
        .value
    }
    
    func showGproof(repository: VaccinationRepositoryProtocol,
                    revocationRepository: CertificateRevocationRepositoryProtocol,
                    certLogic: DCCCertLogicProtocol,
                    userDefaults: Persistence,
                    boosterAsTest: Bool) {
    }
    
    func scanQRCode() -> Promise<ScanResult> {
        .value(.success(""))
    }
    
    func showCertificate(_ certificate: ExtendedCBORWebToken?, _2GContext: Bool, userDefaults: Persistence) {

    }
    
    func showError(_ certificate: ExtendedCBORWebToken?,
                   error: Error,
                   _2GContext: Bool,
                   userDefaults: Persistence) -> Promise<ExtendedCBORWebToken> {
        .value(ExtendedCBORWebToken(
            vaccinationCertificate: .mockTestCertificate,
            vaccinationQRCodeData: "")
        )
    }
}
