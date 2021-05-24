//
//  CertificateSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct CertificateSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let token: ExtendedCBORWebToken

    // MARK: - Lifecycle

    init(token: ExtendedCBORWebToken) {
        self.token = token
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = CertificateViewModel(
            token: token,
            resolvable: resolvable
        )
        let viewController = CertificateViewController(viewModel: viewModel)
        return viewController
    }
}
