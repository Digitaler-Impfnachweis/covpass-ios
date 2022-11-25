//
//  ChooseCheckSituationViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

class ChooseCheckSituationViewControllerSnapShotTests: BaseSnapShotTests {
    private var sut: ChooseCheckSituationViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func configureSut(situationType: CheckSituationType) {
        let (_, resolver) = Promise<Void>.pending()
        let router = ChooseCheckSituationRouterMock()
        var persistence = MockPersistence()
        persistence.checkSituation = situationType.rawValue
        let viewModel = ChooseCheckSituationViewModel(router: router,
                                                      resolver: resolver,
                                                      persistence: persistence)
        sut = .init(viewModel: viewModel)
    }

    func test_withinGermany() {
        configureSut(situationType: .withinGermany)
        verifyView(view: sut.view, height: 1000)
    }

    func test_enteringGermany() {
        configureSut(situationType: .enteringGermany)
        verifyView(view: sut.view, height: 1000)
    }
}
