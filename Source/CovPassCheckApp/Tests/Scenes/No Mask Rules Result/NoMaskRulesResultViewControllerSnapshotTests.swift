//
//  NoMaskRulesResultViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassUI
import PromiseKit
import XCTest

final class NoMaskRulesResultViewControllerSnapshotTests: BaseSnapShotTests {
    private var sut: NoMaskRulesResultViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let (_, resolver) = Promise<Void>.pending()
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 100,
            countdownDuration: 0
        )
        let viewModel = NoMaskRulesResultViewModel(
            countdownTimerModel: countdownTimerModel,
            federalStateCode: "Northrhine-Westphalia",
            resolver: resolver,
            router: NoMaskRulesResultRouterMock()
        )
        sut = .init(viewModel: viewModel)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testDefault() throws {
        verifyView(view: sut.view, height: 1000)
    }
}
