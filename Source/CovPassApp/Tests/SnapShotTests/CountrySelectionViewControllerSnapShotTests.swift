//
//  CountrySelectionViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import Foundation
import PromiseKit

class CountrySelectionViewControllerSnapShotTests: BaseSnapShotTests {
    func testDefault() {
        let (_, resolver) = Promise<String>.pending()
        let vm = CountrySelectionViewModel(router: CountrySelectionRouterMock(),
                                           resolvable: resolver,
                                           countries: CountrySelectionMock.countries,
                                           country: "DE")
        let vc = CountrySelectionViewController(viewModel: vm)
        verifyView(view: vc.view, waitAfter: 0.2, perPixelTolerance: 0.4)
    }
}
