//
//  MaskRequiredResultViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import PromiseKit
import XCTest

final class MaskRequiredResultViewControllerSnapshotTests: BaseSnapShotTests {
    private var sut: MaskRequiredResultViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let (_, resolver) = Promise<Void>.pending()
        let viewModel = MaskRequiredResultViewModel(
            resolver: resolver,
            router: MaskRequiredResultRouterMock()
        )
        sut = .init(viewModel: viewModel)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testDefault() throws {
        verifyView(vc: sut)
    }
}
