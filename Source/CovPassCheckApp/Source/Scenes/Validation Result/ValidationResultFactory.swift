//
//  ValidationResultFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit

struct ValidationResultFactory {
    static func createViewModel(resolvable: Resolver<ExtendedCBORWebToken>,
                                router: ValidationResultRouterProtocol,
                                repository: VaccinationRepositoryProtocol,
                                certificate: ExtendedCBORWebToken?,
                                error: Error?,
                                userDefaults: Persistence) -> ValidationResultViewModel {
        guard let revocationRepository = CertificateRevocationWrapperRepository(),
              let audioPlayer = AudioPlayer()
        else {
            fatalError("Resource mut nor be nil.")
        }
        let revocationKeyFilename = XCConfiguration.certificationRevocationEncryptionKey
        guard error == nil, let certificate = certificate else {
            return ErrorResultViewModel(resolvable: resolvable,
                                        router: router,
                                        repository: repository,
                                        certificate: certificate,
                                        error: error ?? ValidationResultError.technical,
                                        userDefaults: userDefaults,
                                        revocationKeyFilename: revocationKeyFilename,
                                        revocationRepository: revocationRepository,
                                        audioPlayer: audioPlayer)
        }

        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 120,
            countdownDuration: 60
        )

        if certificate.vaccinationCertificate.hcert.dgc.r?.isEmpty == false {
            return RecoveryResultViewModel(resolvable: resolvable,
                                           router: router,
                                           repository: repository,
                                           certificate: certificate,
                                           userDefaults: userDefaults,
                                           revocationKeyFilename: revocationKeyFilename,
                                           countdownTimerModel: countdownTimerModel,
                                           revocationRepository: revocationRepository,
                                           audioPlayer: audioPlayer)
        }
        if certificate.vaccinationCertificate.hcert.dgc.t?.isEmpty == false {
            return TestResultViewModel(resolvable: resolvable,
                                       router: router,
                                       repository: repository,
                                       certificate: certificate,
                                       userDefaults: userDefaults,
                                       revocationKeyFilename: revocationKeyFilename,
                                       countdownTimerModel: countdownTimerModel,
                                       revocationRepository: revocationRepository,
                                       audioPlayer: audioPlayer)
        }
        return VaccinationResultViewModel(resolvable: resolvable,
                                          router: router,
                                          repository: repository,
                                          certificate: certificate,
                                          userDefaults: userDefaults,
                                          revocationKeyFilename: revocationKeyFilename,
                                          countdownTimerModel: countdownTimerModel,
                                          revocationRepository: revocationRepository,
                                          audioPlayer: audioPlayer)
    }
}
