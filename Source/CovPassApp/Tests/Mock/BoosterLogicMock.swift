//
//  BoosterLogicMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit

class BoosterLogicMock: BoosterLogicProtocol {
    var boosterCandidates = [BoosterCandidate]()

    var checkForNewBoosterVaccinationsIfNeededResult: Promise<Bool>?
    func checkForNewBoosterVaccinationsIfNeeded(_: [CertificatePair]) -> Promise<Bool> {
        checkForNewBoosterVaccinationsIfNeededResult ?? Promise.value(false)
    }

    var checkForNewBoosterVaccinationsResult: Promise<Bool>?
    func checkForNewBoosterVaccinations(_: [CertificatePair]) -> Promise<Bool> {
        checkForNewBoosterVaccinationsResult ?? Promise.value(false)
    }

    func checkCertificates(_ certificates: [ExtendedCBORWebToken]) -> BoosterCandidate? {
        boosterCandidates.first(where: { $0.vaccinationIdentifier == certificates.first?.vaccinationCertificate.hcert.dgc.uvci })
    }

    func updateBoosterCandidate(_ boosterCandidate: BoosterCandidate) {
        var exists = false
        var candidates = [BoosterCandidate]()
        for b in boosterCandidates {
            if b.vaccinationIdentifier == boosterCandidate.vaccinationIdentifier {
                candidates.append(boosterCandidate)
                exists = true
            } else {
                candidates.append(b)
            }
        }
        if !exists {
            candidates.append(boosterCandidate)
        }
        boosterCandidates = candidates
    }

    func deleteBoosterCandidate(forCertificate certificate: ExtendedCBORWebToken) {
        var candidates = [BoosterCandidate]()
        for b in boosterCandidates {
            if b.vaccinationIdentifier != certificate.vaccinationCertificate.hcert.dgc.uvci {
                candidates.append(b)
            }
        }
        boosterCandidates = candidates
    }
}
