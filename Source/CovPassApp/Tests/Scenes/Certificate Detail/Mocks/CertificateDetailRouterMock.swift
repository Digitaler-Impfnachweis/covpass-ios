//
//  CertificateDetailRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit
import XCTest

final class CertificateDetailRouterMock: CertificateDetailRouterProtocol {
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    let expectationShowReissue = XCTestExpectation(description: "expectationShowReissue")
    let showCertificateExpectation = XCTestExpectation(description: "showCertificateExpectation")
    let showQRCodeScannerExpectation = XCTestExpectation(description: "showQRCodeScannerExpectation")
    var receivedReissueTokens: [ExtendedCBORWebToken] = []

    func showCertificate(for _: ExtendedCBORWebToken) -> Promise<Void> {
        showCertificateExpectation.fulfill()
        return .value
    }

    func showDetail(for _: ExtendedCBORWebToken) -> Promise<CertificateDetailSceneResult> {
        .value(.addNewCertificate)
    }

    func showWebview(_: URL) {}

    func showReissue(for tokens: [ExtendedCBORWebToken], context _: ReissueContext) -> Promise<Void> {
        receivedReissueTokens = tokens
        expectationShowReissue.fulfill()
        return .value
    }

    func showStateSelection() -> Promise<Void> { .value }
}
