//
//  MaskRequiredResultViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit

private enum Constants {
    static let title = "".localized
    static let subtitle = "".localized
    static let description = "".localized
}

final class MaskRequiredResultViewModel: MaskRequiredResultViewModelProtocol {
    let title = Constants.title
    let subtitle = Constants.subtitle
    let description = Constants.description
    let reasonViewModels: [MaskRequiredReasonViewModelProtocol] = []
    private let resolver: Resolver<Void>
    private let router: MaskRequiredResultRouterProtocol

    init(resolver: Resolver<Void>, router: MaskRequiredResultRouterProtocol) {
        self.resolver = resolver
        self.router = router
    }

    func close() {
        resolver.fulfill_()
    }

    func rescan() {
        resolver.fulfill_()
        router.rescan()
    }
}
