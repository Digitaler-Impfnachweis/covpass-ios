//
//  ValidatorOverviewSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct ValidatorOverviewSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: ValidatorOverviewRouterProtocol

    // MARK: - Lifecycle

    init(router: ValidatorOverviewRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
        let bundle = Bundle.main
        let filename = (
            Locale.current.isGerman() ?
                "privacy-covpasscheck-de" : "privacy-covpasscheck-en"
        ) + ".html"
        guard let privacyFile = try? bundle.loadString(resource: filename, encoding: .utf8) else {
            fatalError("Failed to load privacy file.")
        }
        guard let revocationRepository = CertificateRevocationWrapperRepository() else {
            fatalError("Revocation Repository can't be initialized.")
        }
        guard let audioPlayer = AudioPlayer() else {
            fatalError("Audio player can't be initialized.")
        }
        let repository = VaccinationRepository.create()
        let certLogic = DCCCertLogic.create()
        let viewModel = ValidatorOverviewViewModel(router: router,
                                                   repository: repository,
                                                   revocationRepository: revocationRepository,
                                                   certificateHolderStatus: CertificateHolderStatusModel(dccCertLogic: certLogic),
                                                   certLogic: certLogic,
                                                   userDefaults: UserDefaultsPersistence(),
                                                   privacyFile: privacyFile,
                                                   audioPlayer: audioPlayer)
        let viewController = ValidatorOverviewViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
