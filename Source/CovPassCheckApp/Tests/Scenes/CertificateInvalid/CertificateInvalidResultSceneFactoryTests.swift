//
//  CertificateInvalidResultSceneFactoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit
import XCTest

final class CertificateInvalidResultSceneFactoryTests: XCTestCase {
    private var sut: CertificateInvalidResultSceneFactory!
    override func setUpWithError() throws {
        let token = try ExtendedCBORWebToken.mock()
        sut = .init(
            router: CertificateInvalidResultRouterMock(),
            token: token,
            rescanIsHidden: false
        )
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testMake() {
        // Given
        let (_, resolver) = Promise<ValidatorDetailSceneResult>.pending()

        // When
        let viewController = sut.make(resolvable: resolver)

        // Then
        XCTAssertTrue(viewController is CertificateInvalidResultViewController)
    }
}
