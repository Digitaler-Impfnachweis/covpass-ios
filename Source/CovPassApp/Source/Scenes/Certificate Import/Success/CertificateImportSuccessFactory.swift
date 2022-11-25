//
//  CertificateImportSuccessFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import UIKit

public struct CertificateImportSuccessFactory: ResolvableSceneFactory {
    public func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = CertificateImportSuccessViewViewModel(resolver: resolvable)
        let viewController = ResultViewViewController(viewModel: viewModel)
        return viewController
    }
}
