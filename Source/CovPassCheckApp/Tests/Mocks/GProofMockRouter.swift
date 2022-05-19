//
//  GProofMockRouter.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit
import Foundation
import XCTest

class GProofMockRouter: GProofRouterProtocol {
    var qrCodeScanShouldCanceled = false
    var errorShown = false
    var certificateShown = XCTestExpectation()
    var showDifferentPersonShown = XCTestExpectation()
    var recovery90DaysErrorShown = XCTestExpectation()
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()

    func scanQRCode() -> Promise<ScanResult> {
        qrCodeScanShouldCanceled ? .init { resolver in resolver.cancel() } : .value(.success(""))
    }
    
    func showCertificate(_ certificate: ExtendedCBORWebToken?,
                         _2GContext: Bool,
                         error: Error?,
                         userDefaults: Persistence,
                         buttonHidden: Bool) -> Promise<ExtendedCBORWebToken> {
        certificateShown.fulfill()
        return .value(
            ExtendedCBORWebToken(
                vaccinationCertificate: .mockVaccinationCertificate,
                vaccinationQRCodeData: ""
            )
        )
    }
    
    func showError(error: Error) {
        errorShown = true
    }
    func showRecovery90DaysError(error: Error) {
        recovery90DaysErrorShown.fulfill()
    }
    
    func showDifferentPerson(firstResultCert: CBORWebToken, scondResultCert: CBORWebToken) -> Promise<GProofResult> {
        showDifferentPersonShown.fulfill()
        return .value(.cancel)
    }
    
    func showStart() {
        
    }
    
    func showRevocation(token: ExtendedCBORWebToken, keyFilename: String) -> Promise<Void> {
        .init(error: NSError(domain: "TEST", code: 0, userInfo: nil))
    }
}
