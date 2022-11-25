//
//  BoosterLogic.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public protocol BoosterLogicProtocol {
    func checkForNewBoosterVaccinationsIfNeeded(_ users: [CertificatePair]) -> Promise<Bool>
    func checkForNewBoosterVaccinations(_ users: [CertificatePair]) -> Promise<Bool>
    func checkCertificates(_ certificates: [ExtendedCBORWebToken]) -> BoosterCandidate?
    func updateBoosterCandidate(_ boosterCandidate: BoosterCandidate)
    func deleteBoosterCandidate(forCertificate certificate: ExtendedCBORWebToken)
}

public struct BoosterLogic: BoosterLogicProtocol {
    private let certLogic: DCCCertLogicProtocol
    private let userDefaults: Persistence
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()

    public init(certLogic: DCCCertLogicProtocol, userDefaults: Persistence) {
        self.certLogic = certLogic
        self.userDefaults = userDefaults
    }

    /// Check for new booster vaccinations only once a day
    public func checkForNewBoosterVaccinationsIfNeeded(_ users: [CertificatePair]) -> Promise<Bool> {
        firstly {
            Promise { seal in
                if let lastUpdated = try userDefaults.fetch(UserDefaults.keyLastCheckedBooster) as? Date,
                   let date = Calendar.current.date(byAdding: .hour, value: 1, to: lastUpdated),
                   Date() < date {
                    // Only check once a day
                    seal.reject(PromiseCancelledError())
                    return
                }
                seal.fulfill_()
            }
        }
        .then(on: .global()) {
            checkForNewBoosterVaccinations(users)
        }
        .map(on: .global()) { newBoosterVaccination in
            try self.userDefaults.store(UserDefaults.keyLastCheckedBooster, value: Date())
            return newBoosterVaccination
        }
    }

    /// Check all users and their certificates for new booster vaccination qualifications
    /// A user is qualified for a booster vaccination if at least one booster rule returns a valid result
    /// Returns true, if a new user is qualified
    public func checkForNewBoosterVaccinations(_ users: [CertificatePair]) -> Promise<Bool> {
        Promise { seal in
            var newQualification = false
            for user in users {
                let sortedCertificates = user.certificates.sortLatest()
                // get most recent vaccination and recovery certificate
                let mostRecentVaccinationCertificate = sortedCertificates.first(where: { $0.vaccinationCertificate.hcert.dgc.v?.isEmpty == false })
                let recoveryCertificate = sortedCertificates.first(where: { $0.vaccinationCertificate.hcert.dgc.r?.isEmpty == false })
                guard var vaccinationCertificate = mostRecentVaccinationCertificate else { continue }

                // combine vaccination and recovery certificate for booster rule check
                vaccinationCertificate.vaccinationCertificate.hcert.dgc.r = recoveryCertificate?.vaccinationCertificate.hcert.dgc.r

                do {
                    let result = try certLogic.validate(
                        type: .booster,
                        countryCode: "DE",
                        region: nil,
                        validationClock: Date(),
                        certificate: vaccinationCertificate.vaccinationCertificate
                    )
                    var boosterCandidate = boosterCandidateForUser(certificate: vaccinationCertificate)
                    let passedRules = result.filter { $0.result == .passed }.compactMap(\.rule)
                    let rulesChanged = boosterCandidate.validationRules != passedRules
                    if !passedRules.isEmpty, rulesChanged {
                        // user is qualified for a booster vaccination
                        boosterCandidate.vaccinationIdentifier = vaccinationCertificate.vaccinationCertificate.hcert.dgc.uvci
                        boosterCandidate.validationRules = passedRules
                        boosterCandidate.state = .new
                        updateBoosterCandidate(boosterCandidate)
                        newQualification = true
                    } else if passedRules.isEmpty, !boosterCandidate.validationRules.isEmpty {
                        // rules changed and user is not qualified for a booster anymore
                        try? deleteUserDefaultsBoosterCandidates(
                            with: boosterCandidate.dgc
                        )
                    }

                } catch {
                    seal.reject(error)
                    return
                }
            }
            seal.fulfill(newQualification)
        }
    }

    /// Check all certificates of a user for valid booster vaccination qualification
    public func checkCertificates(_ certificates: [ExtendedCBORWebToken]) -> BoosterCandidate? {
        guard let cert = certificates.first else { return nil }
        return boosterCandidateForUser(certificate: cert)
    }

    /// Update the booster candidate
    public func updateBoosterCandidate(_ boosterCandidate: BoosterCandidate) {
        var boosterCandidates = userDefaultsBoosterCandidates()
        boosterCandidates.replace(boosterCandidate)
        boosterCandidates.appendIfNotContained(boosterCandidate)
        try? updateUserDefaultsBoosterCandidates(boosterCandidates)
    }

    private func updateUserDefaultsBoosterCandidates(_ boosterCandidates: [BoosterCandidate]) throws {
        let data = try jsonEncoder.encode(boosterCandidates)
        try userDefaults.store(UserDefaults.keyBoosterCandidates, value: data)
    }

    /// Delete booster candidate for user
    public func deleteBoosterCandidate(forCertificate certificate: ExtendedCBORWebToken) {
        let boosterCandidates = userDefaultsBoosterCandidates()
        let updatedCandidates = boosterCandidates.filter { $0.vaccinationIdentifier != certificate.vaccinationCertificate.hcert.dgc.uvci }
        try? updateUserDefaultsBoosterCandidates(updatedCandidates)
    }

    // MARK: - Helpers

    /// Returns the booster candidate for given user
    private func boosterCandidateForUser(certificate: ExtendedCBORWebToken) -> BoosterCandidate {
        userDefaultsBoosterCandidate(with: certificate.vaccinationCertificate.hcert.dgc) ?? BoosterCandidate(certificate: certificate)
    }

    private func userDefaultsBoosterCandidate(with dgc: DigitalGreenCertificate) -> BoosterCandidate? {
        let boosterCandidates = userDefaultsBoosterCandidates()
        return boosterCandidates.first(where: { dgc == $0.dgc })
    }

    private func userDefaultsBoosterCandidates() -> [BoosterCandidate] {
        guard let data = try? userDefaults.fetch(UserDefaults.keyBoosterCandidates) as? Data else {
            return []
        }
        let boosterCandidates = try? jsonDecoder.decode(
            [BoosterCandidate].self,
            from: data
        )
        return boosterCandidates ?? []
    }

    private func deleteUserDefaultsBoosterCandidates(with dgc: DigitalGreenCertificate) throws {
        let candidates = userDefaultsBoosterCandidates()
            .filter { candidate in
                candidate.dgc != dgc
            }
        try updateUserDefaultsBoosterCandidates(candidates)
    }
}

private extension Array where Element == BoosterCandidate {
    mutating func replace(_ candidate: BoosterCandidate) {
        self = map { $0 == candidate ? candidate : $0 }
    }

    mutating func appendIfNotContained(_ candidate: BoosterCandidate) {
        if !contains(candidate) {
            append(candidate)
        }
    }
}
