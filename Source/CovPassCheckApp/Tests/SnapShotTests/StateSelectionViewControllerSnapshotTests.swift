//
//  StateSelectionViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit

class StateSelectionViewControllerSnapshotTests: BaseSnapShotTests {
    private var sut: StateSelectionViewController!
    private var persistence: UserDefaultsPersistence!
    private var promise: Promise<Void>!

    override func setUpWithError() throws {
        persistence = UserDefaultsPersistence()
        let (promise, resolver) = Promise<Void>.pending()
        self.promise = promise
        let vm = StateSelectionViewModel(persistence: persistence, resolver: resolver)
        sut = .init(viewModel: vm)
    }

    override func tearDownWithError() throws {
        promise = nil
        persistence = nil
        sut = nil
    }

    func test_default() {
        verifyView(view: sut.view)
    }
}
