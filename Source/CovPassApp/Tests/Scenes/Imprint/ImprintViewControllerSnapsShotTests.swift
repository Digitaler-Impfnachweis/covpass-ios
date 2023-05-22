//
//  ImprintWebviewViewControllerTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import XCTest

class ImprintViewControllerSnapsShotTests: BaseSnapShotTests {
    private var sut: UIViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = ImprintSceneFactory().make()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testDefault() {
        verifyView(view: sut.view, height: 1000)
    }
}
