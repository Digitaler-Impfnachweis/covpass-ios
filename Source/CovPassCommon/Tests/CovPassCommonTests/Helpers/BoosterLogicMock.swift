//
//  BoosterLogicMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon
import PromiseKit

struct BoosterLogicMock: BoosterLogicProtocol {
    func checkForNewBoosterVaccinationsIfNeeded(_ users: [CertificatePair]) -> Promise<Bool> {
        Promise.value(false)
    }

    func checkForNewBoosterVaccinations(_ users: [CertificatePair]) -> Promise<Bool> {
        Promise.value(false)
    }

    func checkCertificates(_ certificates: [ExtendedCBORWebToken]) -> BoosterCandidate? {
        nil
    }

    func updateBoosterCandidate(_ boosterCandidate: BoosterCandidate) {}

    func deleteBoosterCandidate(forCertificate certificate: ExtendedCBORWebToken) {}
}
