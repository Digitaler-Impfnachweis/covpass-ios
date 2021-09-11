//
//  BoosterLogic.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import CertLogic

public struct BoosterCandidate: Codable {

    public enum BoosterState: String, Codable {
        // Not qualifified for a booster
        case none
        // New qualification for a booster
        case new
        // Qualified for a booster but already shown
        case qualified
    }

    public var name: String
    public var birthdate: String
    // identifier is used to identify the vaccination on which the rules were checked on
    public var vaccinationIdentifier: String
    public var state: BoosterState
    // All passed validation rules for this user
    public var validationRules: [Rule]

    public init(name: String, birthdate: String, vaccinationIdentifier: String, state: BoosterState, validationRules: [Rule]) {
        self.name = name
        self.birthdate = birthdate
        self.vaccinationIdentifier = vaccinationIdentifier
        self.state = state
        self.validationRules = validationRules
    }

    public init(certificate: ExtendedCBORWebToken) {
        name = certificate.vaccinationCertificate.hcert.dgc.nam.fullName
        birthdate = certificate.vaccinationCertificate.hcert.dgc.dobString ?? ""
        vaccinationIdentifier = certificate.vaccinationCertificate.hcert.dgc.uvci
        state = .none
        validationRules = []
    }
}

extension BoosterCandidate: Equatable {
    public static func == (lhs: BoosterCandidate, rhs: BoosterCandidate) -> Bool {
        lhs.name == rhs.name && lhs.birthdate == rhs.birthdate
    }
}

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

    public init(certLogic: DCCCertLogicProtocol, userDefaults: Persistence) {
        self.certLogic = certLogic
        self.userDefaults = userDefaults
    }

    /// Check for new booster vaccinations only once a day
    public func checkForNewBoosterVaccinationsIfNeeded(_ users: [CertificatePair]) -> Promise<Bool> {
        firstly {
            Promise { seal in
                if let lastUpdated = try userDefaults.fetch(UserDefaults.keyLastCheckedBooster) as? Date,
                   let date = Calendar.current.date(byAdding: .day, value: 1, to: lastUpdated),
                   Date() < date
                {
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
                let sortedCertificates = CertificateSorter.sort(user.certificates)
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
                        validationClock: Date(),
                        certificate: vaccinationCertificate.vaccinationCertificate
                    )
                    var boosterCandiate = boosterCandidateForUser(certificate: vaccinationCertificate)
                    let passedRules = result.filter({ $0.result == .passed }).compactMap({ $0.rule })
                    let rulesChanged = boosterCandiate.validationRules != passedRules
                    if !passedRules.isEmpty && rulesChanged {
                        // user is qualified for a booster vaccination
                        boosterCandiate.vaccinationIdentifier = vaccinationCertificate.vaccinationCertificate.hcert.dgc.uvci
                        boosterCandiate.validationRules = passedRules
                        boosterCandiate.state = .new
                        updateBoosterCandidate(boosterCandiate)
                        newQualification = true
                    } else if passedRules.isEmpty && !boosterCandiate.validationRules.isEmpty {
                        // rules changed and user is not qualified for a booster anymore
                        deleteBoosterCandidate(forCertificate: vaccinationCertificate)
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
        var boosterCandidates = [BoosterCandidate]()
        if let data = try? userDefaults.fetch(UserDefaults.keyBoosterCandidates) as? Data {
            boosterCandidates = (try? JSONDecoder().decode([BoosterCandidate].self, from: data)) ?? []
        }
        var updatedCandidates = boosterCandidates.map { $0 == boosterCandidate ? boosterCandidate : $0 }
        if !updatedCandidates.contains(boosterCandidate) {
            updatedCandidates.append(boosterCandidate)
        }
        guard let updatedData = try? JSONEncoder().encode(updatedCandidates) else { return }
        try? userDefaults.store(UserDefaults.keyBoosterCandidates, value: updatedData)
    }

    /// Delete booster candidate for user
    public func deleteBoosterCandidate(forCertificate certificate: ExtendedCBORWebToken) {
        guard let data = try? userDefaults.fetch(UserDefaults.keyBoosterCandidates) as? Data,
           let boosterCandidates = try? JSONDecoder().decode([BoosterCandidate].self, from: data)
        else { return }
        let updatedCandidates = boosterCandidates.filter { $0.vaccinationIdentifier != certificate.vaccinationCertificate.hcert.dgc.uvci }
        guard let updatedData = try? JSONEncoder().encode(updatedCandidates) else { return }
        try? userDefaults.store(UserDefaults.keyBoosterCandidates, value: updatedData)
    }

    // MARK: - Helpers

    /// Returns the booster candidate for given user
    private func boosterCandidateForUser(certificate: ExtendedCBORWebToken) -> BoosterCandidate {
        let name = certificate.vaccinationCertificate.hcert.dgc.nam.fullName
        let birthdate = certificate.vaccinationCertificate.hcert.dgc.dobString ?? ""
        return boosterCandidateForUser(name: name, birthdate: birthdate) ?? BoosterCandidate(certificate: certificate)
    }

    private func boosterCandidateForUser(name: String, birthdate: String) -> BoosterCandidate? {
        guard let data = try? userDefaults.fetch(UserDefaults.keyBoosterCandidates) as? Data,
           let boosterCandidates = try? JSONDecoder().decode([BoosterCandidate].self, from: data)
        else { return nil }
        return boosterCandidates.first(where: { $0.name == name && $0.birthdate == birthdate })
    }
}
