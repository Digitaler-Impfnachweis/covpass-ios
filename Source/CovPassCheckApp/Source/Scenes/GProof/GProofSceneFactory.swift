//
//  GProofSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit
import CovPassCommon
import PromiseKit

struct GProofSceneFactory: ResolvableSceneFactory {
    
    // MARK: - Properties

    private let router: GProofRouterProtocol
    private let boosterAsTest: Bool
    
    // MARK: - Lifecycle
    
    init(router: GProofRouterProtocol, boosterAsTest: Bool) {
        self.router = router
        self.boosterAsTest = boosterAsTest
    }

    func make(resolvable: Resolver<ExtendedCBORWebToken>) -> UIViewController {
        guard let revocationRepository = CertificateRevocationWrapperRepository(),
              let audioPlayer = AudioPlayer()
        else {
            fatalError("Class can't be initialized.")
        }
        let repository = VaccinationRepository.create()
        let certLogic = DCCCertLogic.create()
        let userDefaults = UserDefaultsPersistence()
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 120,
            countdownDuration: 60
        )
        let viewModel = GProofViewModel(resolvable: resolvable,
                                        router: router,
                                        repository: repository,
                                        revocationRepository: revocationRepository,
                                        certLogic: certLogic,
                                        userDefaults: userDefaults,
                                        boosterAsTest: boosterAsTest,
                                        countdownTimerModel: countdownTimerModel,
                                        audioPlayer: audioPlayer)
        let viewController = GProofViewController(viewModel: viewModel)
        return viewController
    }
}
