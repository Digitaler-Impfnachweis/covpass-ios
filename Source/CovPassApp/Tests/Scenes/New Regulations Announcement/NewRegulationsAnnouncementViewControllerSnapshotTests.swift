//
//  NewRegulationsAnnouncementViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassUI
import PromiseKit
import UIKit
import XCTest

class NewRegulationsAnnouncementViewControllerSnapshotTests: BaseSnapShotTests {
    private var sut: NewRegulationsAnnouncementViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let (_, resolver) = Promise<Void>.pending()
        let viewModel = NewRegulationsAnnouncementViewModel(resolver: resolver)
        sut = .init(viewModel: viewModel)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testDefault() {
        verifyView(view: sut.view, height: 1200)
    }
}
