//
//  CertificateDetailRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import Foundation
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

final class CertificateDetailRouterMock: CertificateDetailRouterProtocol {
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    let expectationShowReissue = XCTestExpectation(description: "expectationShowReissue")
    let showCertificateExpectation = XCTestExpectation(description: "showCertificateExpectation")
    let showQRCodeScannerExpectation = XCTestExpectation(description: "showQRCodeScannerExpectation")
    var receivedReissueTokens: [ExtendedCBORWebToken] = []

    func showCertificate(for token: ExtendedCBORWebToken) -> Promise<Void> {
        showCertificateExpectation.fulfill()
        return .value
    }

    func showDetail(for certificate: ExtendedCBORWebToken) -> Promise<CertificateDetailSceneResult> {
        .value(.addNewCertificate)
    }

    func showWebview(_ url: URL) {}

    func showReissue(for tokens: [ExtendedCBORWebToken], context: ReissueContext) -> Promise<Void> {
        receivedReissueTokens = tokens
        expectationShowReissue.fulfill()
        return .value
    }

    func showStateSelection() -> Promise<Void> { .value }
}
