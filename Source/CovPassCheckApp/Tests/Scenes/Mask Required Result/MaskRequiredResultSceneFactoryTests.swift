//
//  MaskRequiredResultSceneFactoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import PromiseKit
import UIKit
import XCTest

final class MaskRequiredResultSceneFactoryTests: XCTestCase {
    private var sut: MaskRequiredResultSceneFactory!
    override func setUpWithError() throws {
        sut = .init(
            router: MaskRequiredResultRouterMock()
        )
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testMake() {
        // Given
        let (_, resolver) = Promise<Void>.pending()

        // When
        let viewController = sut.make(resolvable: resolver)

        // Then
        XCTAssertTrue(viewController is MaskRequiredResultViewController)
    }
}
