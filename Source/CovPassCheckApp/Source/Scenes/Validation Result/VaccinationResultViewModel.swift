//
//  VaccinationResultViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class VaccinationResultViewModel: ValidationResultViewModel {
    
    // MARK: - Properties

    weak var delegate: ResultViewModelDelegate?
    let countdownTimerModel: CountdownTimerModel?
    var resolvable: Resolver<ExtendedCBORWebToken>
    var router: ValidationResultRouterProtocol
    var repository: VaccinationRepositoryProtocol
    var certificate: ExtendedCBORWebToken?
    var revocationKeyFilename: String
    let revocationRepository: CertificateRevocationRepositoryProtocol?
    let audioPlayer: AudioPlayerProtocol?

    var icon: UIImage? {
        .resultSuccess
    }

    var resultTitle: String {
        "validation_check_popup_valid_vaccination_recovery_title".localized
    }

    var resultBody: String {
        "validation_check_popup_valid_vaccination_recovery_message".localized
    }

    var paragraphs: [Paragraph] {
        guard let dgc = certificate?.vaccinationCertificate.hcert.dgc else {
            return []
        }
        return [
            Paragraph(
                icon: .data,
                title: dgc.nam.fullName,
                subtitle: "\(dgc.nam.fullNameTransliterated)\n\(String(format: "validation_check_popup_valid_vaccination_date_of_birth".localized, DateUtils.displayDateOfBirth(dgc)))"
            )
        ]
    }

    var info: String? {
        "validation_check_popup_valid_vaccination_recovery_note".localized
    }

    var buttonHidden: Bool = false
    var userDefaults: Persistence
    var isLoadingScan: Bool = false {
        didSet {
            delegate?.viewModelDidUpdate()
        }
    }
    
    // MARK: - Lifecycle

    init(resolvable: Resolver<ExtendedCBORWebToken>,
         router: ValidationResultRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         certificate: ExtendedCBORWebToken?,
         userDefaults: Persistence,
         revocationKeyFilename: String,
         countdownTimerModel: CountdownTimerModel,
         revocationRepository: CertificateRevocationRepositoryProtocol,
         audioPlayer: AudioPlayerProtocol
    ) {
        self.audioPlayer = audioPlayer
        self.revocationRepository = revocationRepository
        self.resolvable = resolvable
        self.router = router
        self.repository = repository
        self.certificate = certificate
        self.userDefaults = userDefaults
        self.revocationKeyFilename = revocationKeyFilename
        self.countdownTimerModel = countdownTimerModel
        countdownTimerModel.onUpdate = onCountdownTimerModelUpdate
        countdownTimerModel.start()
    }

    private func onCountdownTimerModelUpdate(countdownTimerModel: CountdownTimerModel) {
        if countdownTimerModel.shouldDismiss {
            cancel()
        } else {
            delegate?.viewModelDidUpdate()
        }
    }

    func scanCertificateStarted() {
        isLoadingScan = true
    }
    
    func scanCertificateEnded() {
        isLoadingScan = false
    }
}
