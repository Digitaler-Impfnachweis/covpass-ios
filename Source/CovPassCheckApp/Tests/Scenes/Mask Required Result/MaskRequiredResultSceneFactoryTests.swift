//
//  MaskRequiredResultSceneFactoryTests.swift
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

final class MaskRequiredResultSceneFactoryTests: XCTestCase {
    private var sut: MaskRequiredResultSceneFactory!
    override func setUpWithError() throws {
        sut = .init(
            router: MaskRequiredResultRouterMock(),
            reasonType: .functional,
            secondCertificateHintHidden: true,
            token: CBORWebToken.mockVaccinationCertificate.extended()
        )
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testMake() {
        // Given
        var persistence = UserDefaultsPersistence()
        persistence.stateSelection = "NW"
        let (_, resolver) = Promise<ValidatorDetailSceneResult>.pending()

        // When
        let viewController = sut.make(resolvable: resolver)

        // Then
        XCTAssertTrue(viewController is MaskRequiredResultViewController)
    }
}
