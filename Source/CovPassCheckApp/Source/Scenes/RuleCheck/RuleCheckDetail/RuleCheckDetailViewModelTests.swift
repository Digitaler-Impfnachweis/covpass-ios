//
//  RuleCheckDetailViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import PromiseKit
import XCTest

class RuleCheckDetailViewModelTests: XCTestCase {
    private var sut: RuleCheckDetailViewModel!

    override func tearDownWithError() throws {
        sut = nil
    }

    func testItems_tc() {
        // Given
        sut = configureSut(token: .mockTestCertificate)

        // When
        let items = sut.items

        // Then
        let item = items.first { $0.0 == "Testzentrum oder -einrichtung / Testing centre or facility" }
        XCTAssertEqual(item?.1, "Test Center")
    }

    private func configureSut(token: CBORWebToken) -> RuleCheckDetailViewModel {
        let (_, resolver) = Promise<Void>.pending()
        let extendedCBORWebToken = token.extended()
        let sut = RuleCheckDetailViewModel(
            router: RuleCheckDetailRouter(sceneCoordinator: SceneCoordinatorMock()),
            resolvable: resolver,
            result: .init(
                certificate: extendedCBORWebToken,
                result: []
            ),
            country: "FR",
            date: Date(timeIntervalSinceReferenceDate: 0)
        )

        return sut
    }

    func testItems_tc_is_nil() throws {
        // Given
        var cborWebToken = CBORWebToken.mockTestCertificate
        let test = try XCTUnwrap(cborWebToken.hcert.dgc.t?.first)
        test.tc = nil
        cborWebToken.hcert.dgc.t = [test]
        sut = configureSut(token: cborWebToken)

        // When
        let items = sut.items

        // Then
        let item = items.first { $0.0 == "Testzentrum oder -einrichtung / Testing centre or facility" }
        XCTAssertEqual(item?.1, "")
    }
}
