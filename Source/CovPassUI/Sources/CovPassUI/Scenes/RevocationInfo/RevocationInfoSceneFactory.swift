//
//  RevocationInfoSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import UIKit

struct RevocationInfoSceneFactory: ResolvableSceneFactory {
    private let keyFilename: String
    private let router: RevocationInfoRouterProtocol
    private let token: ExtendedCBORWebToken

    init(keyFilename: String, router: RevocationInfoRouterProtocol, token: ExtendedCBORWebToken) {
        self.keyFilename = keyFilename
        self.router = router
        self.token = token
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        guard let pdfGenerator = RevocationPDFGenerator(keyFilename: keyFilename) else {
            fatalError("Failed to instantiate RevocationPDFGenerator.")
        }
        guard let coseSign1Message = try? token.coseSign1Message() else {
            fatalError("Failed to get CoseSign1Message.")
        }
        let viewModel = RevocationInfoViewModel(
            router: router,
            resolver: resolvable,
            pdfGenerator: pdfGenerator,
            fileManager: FileManager.default,
            token: token,
            coseSign1Message: coseSign1Message,
            timestamp: Date()
        )
        let viewController = RevocationInfoViewController(viewModel: viewModel)

        return viewController
    }
}
