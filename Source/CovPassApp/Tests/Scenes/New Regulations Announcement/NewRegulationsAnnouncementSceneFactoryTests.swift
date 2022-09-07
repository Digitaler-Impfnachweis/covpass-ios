//
//  NewRegulationsAnnouncementSceneFactoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import PromiseKit
import XCTest

class NewRegulationsAnnouncementSceneFactoryTests: XCTestCase {
    private var sut: NewRegulationsAnnouncementSceneFactory!
    override func setUpWithError() throws {
        sut = .init()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testInit() {
        // Given
        let (_, resolver) = Promise<Void>.pending()

        // When
        let viewController = sut.make(resolvable: resolver)

        // Then
        XCTAssertTrue(viewController is NewRegulationsAnnouncementViewController)
    }
}
