//
//  RuleCheckDetailViewControllerTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//


@testable import CovPassApp
import PromiseKit
import XCTest

class RuleCheckDetailViewControllerTests: BaseSnapShotTests {
    private var sut: RuleCheckDetailViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let (_, resolver) = Promise<Void>.pending()
        let viewModel = try RuleCheckDetailViewModel(
            router: RuleCheckDetailRouterMock(),
            resolvable: resolver,
            result: .init(certificate: .mock(), result: []),
            country: "DE",
            date: .init(timeIntervalSinceReferenceDate: 0)
        )
        sut = .init(viewModel: viewModel)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testDefault() {
        // Then
        verifyView(view: sut.view, height: 2000)
    }
}
