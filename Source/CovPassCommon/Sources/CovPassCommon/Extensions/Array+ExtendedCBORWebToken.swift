//
//  ExtendedCBORWebToken+Filter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension Array where Element == ExtendedCBORWebToken {
    
    /// Splits the receiver in an array of sub-arrays. Eachs sub-array contains the certificates for one owner.
    var partitionedByOwner: [Self] {
        var partitions = [Self]()
        for extendedCBORWebToken in self {
            if let index = partitions.firstIndex(where: { $0.containsMatching(extendedCBORWebToken) }) {
                partitions[index].append(extendedCBORWebToken)
            } else {
                partitions.append([extendedCBORWebToken])
            }
        }
        return partitions
    }
    
    func filterMatching(_ extendedCBORWebToken: ExtendedCBORWebToken) -> [ExtendedCBORWebToken] {
        filter { $0.matches(extendedCBORWebToken) }
    }
    
    private func containsMatching(_ extendedCBORWebToken: ExtendedCBORWebToken) -> Bool {
        contains { $0.matches(extendedCBORWebToken) }
    }
    
    var qualifiedForReissue: Bool {
        guard filter2Of1.isEmpty else {
            return false
        }
        return !filterBoosterAfterVaccinationAfterRecoveryFromGermany.isEmpty
    }
    
    var reissueProcessInitialNotAlreadySeen: Bool { !reissueProcessInitialAlreadySeen }
    
    var reissueProcessInitialAlreadySeen: Bool { first(where: { $0.reissueProcessInitialAlreadySeen ?? false }) != nil }
    
    var reissueNewBadgeAlreadySeen: Bool { first(where: { $0.reissueProcessNewBadgeAlreadySeen ?? false }) != nil }

    var tokensOfVaccinationWithSingleDoseFromGermany: [ExtendedCBORWebToken] {
        filter {
            guard let vaccinations = $0.vaccinations else {
                return false
            }
            return !vaccinations.filter{ $0.isSingleDoseComplete }.isEmpty
        }.filterIssuedByGerman
    }
    
    var tokensOfVaccinationWithDoubleDoseCompleteFromGermany: [ExtendedCBORWebToken] {
        filter {
            guard let vaccinations = $0.vaccinations else {
                return false
            }
            return !vaccinations.filter{ $0.isDoubleDoseComplete }.isEmpty
        }.filterIssuedByGerman
    }
    
    var tokensOfRecoveryFromGermany: [ExtendedCBORWebToken] {
        let recoveriesIssuedByGerman = filter(by: .recovery).filterIssuedByGerman
        return recoveriesIssuedByGerman.filterOlderThanDoubleDoseVaccination(datesOfGermanDoubleDoseVaccinations: datesOfGermanDoubleDoseVaccinations)
    }
    
    func filterOlderThanDoubleDoseVaccination(datesOfGermanDoubleDoseVaccinations: [Date]) -> [ExtendedCBORWebToken] {
        filter { token in
            datesOfGermanDoubleDoseVaccinations.contains { doubleDoseVaccinationDate in
                return token.firstRecovery!.fr < doubleDoseVaccinationDate
            }
        }
    }
    
    var recoveryDates: [Date] {
        tokensOfRecoveryFromGermany.map{ $0.firstRecovery!.fr }
    }
    
    var datesOfGermanDoubleDoseVaccinations : [Date] {
        tokensOfVaccinationWithDoubleDoseCompleteFromGermany.map{ $0.firstVaccination!.dt }
    }
    
    var filterBoosterAfterVaccinationAfterRecoveryFromGermany: [ExtendedCBORWebToken] {
        guard !tokensOfVaccinationWithSingleDoseFromGermany.isEmpty else {
            return []
        }
        guard !tokensOfVaccinationWithDoubleDoseCompleteFromGermany.isEmpty else {
            return []
        }

        return tokensOfRecoveryFromGermany + tokensOfVaccinationWithSingleDoseFromGermany + tokensOfVaccinationWithDoubleDoseCompleteFromGermany
    }
    
    var sortByIssuedAtTime: [ExtendedCBORWebToken] {
        sorted(by: { c1, c2 -> Bool in
            guard let c1Iat = c1.vaccinationCertificate.iat else {
                return false
            }
            guard let c2Iat = c2.vaccinationCertificate.iat else {
                return true
            }
            return c1Iat >= c2Iat
        })
    }
    
    var sortByDateOfBirth: [ExtendedCBORWebToken] {
        sorted(by: { c1, c2 -> Bool in
            guard let c1Iat = c1.dateOfBirth else {
                return false
            }
            guard let c2Iat = c2.dateOfBirth else {
                return true
            }
            return c1Iat > c2Iat
        })
    }
    
    var sortTestsByDateTimeOfSampleCollection: [ExtendedCBORWebToken] {
        sorted(by: {
            guard let lhs = $0.firstTest?.sc,
                    let rhs = $1.firstTest?.sc else {
                return false
            }
            return lhs > rhs
        })
    }
    
    var sortByVaccinationDate: [ExtendedCBORWebToken] {
        sorted(by: { c1, c2 -> Bool in
            return c1.firstVaccination?.dt ?? Date() > c2.firstVaccination?.dt ?? Date()
        })
    }
    
    var sortByFirstPositiveResultDate: [ExtendedCBORWebToken] {
        sorted(by: { c1, c2 -> Bool in
            return c1.firstRecovery?.fr ?? Date() > c2.firstRecovery?.fr ?? Date()
        })
    }
    
    var filterNegativePCRTestsNotOlderThan72Hours: [ExtendedCBORWebToken] {
        filter {
            if let t = $0.firstTest, t.isPCR, !t.isPositive, Date() <= Calendar.current.date(byAdding: .hour, value: 72, to: t.sc) ?? Date() {
                return true
            }
            return false
        }
    }
    
    var filterIssuedByGerman: [ExtendedCBORWebToken] {
        filter {
            $0.vaccinationCertificate.isGermanIssuer
        }
    }
    
    var filterNegativeQuickTestsNotOlderThan48Hours: [ExtendedCBORWebToken] {
        filter {
            if let t = $0.firstTest, !t.isPCR, !t.isPositive, Date() <= Calendar.current.date(byAdding: .hour, value: 48, to: t.sc) ?? Date() {
                return true
            }
            return false
        }
    }
    
    var filterBoosters: [ExtendedCBORWebToken] {
        filter {
            if let v = $0.firstVaccination, v.isBoosted(vaccinations: vaccinations, recoveries: recoveries) {
                return true
            }
            return false
        }
    }
    
    var filter2Of1: [ExtendedCBORWebToken] {
        filter {
            if let v = $0.firstVaccination, v.is2Of1 {
                return true
            }
            return false
        }
    }

    var sortedByDn: [ExtendedCBORWebToken] {
        sorted { token1, token2 in
            guard let vaccination1 = token1.vaccinationCertificate.hcert.dgc.v?.first else {
                return false
            }
            guard let vaccination2 = token2.vaccinationCertificate.hcert.dgc.v?.first else {
                return true
            }
            return vaccination1 < vaccination2
        }
    }
    
    var filterNotFullImmunization: [ExtendedCBORWebToken] {
        filter {
            if let v = $0.firstVaccination, !v.fullImmunization {
                return true
            }
            return false
        }
    }
    
    var filterVaccinations: [ExtendedCBORWebToken] {
        filter { $0.vaccinations != nil }
    }
    
    var filterRecoveries: [ExtendedCBORWebToken] {
        filter { $0.recoveries != nil }
    }
    
    var vaccinations: [Vaccination] {
        filterVaccinations.map{ $0.vaccinations }.compactMap{$0}.flatMap{$0}
    }
    
    var recoveries: [Recovery] {
        filterRecoveries.map{ $0.recoveries }.compactMap{$0}.flatMap{$0}
    }
    
    var firstNotBosstedValidFullImmunization: ExtendedCBORWebToken? {
        first(where: {
            if let v = $0.firstVaccination, v.fullImmunization, v.fullImmunizationValid, !v.isBoosted(vaccinations: vaccinations, recoveries: recoveries) /* Boosters are currently lower prioritized (see 5.1) */ {
                return true
            }
            return false
        })
    }
    
    var firstNotValidButFullImmunization: ExtendedCBORWebToken? {
        first(where: {
            if let v = $0.firstVaccination, v.fullImmunization, !v.fullImmunizationValid {
                return true
            }
            return false
        })
    }
    
    var filterRecoveryWhoseDateIsStillValid: [ExtendedCBORWebToken]  {
        filter {
            if let r = $0.firstRecovery, Date() <= r.du {
                return true
            }
            return false
        }
    }
    
    var filterRecoveryWhoseDateNotAnyMoreValid: [ExtendedCBORWebToken]  {
        filter {
            if let r = $0.firstRecovery, Date() > r.du {
                return true
            }
            return false
        }
    }
    
    var filterAllTestsNegativeAndNotValid: [ExtendedCBORWebToken] {
        filter {
            if let t = $0.firstTest, !t.isPositive, !t.isValid {
                return true
            }
            return false
        }
    }
    
    var filterValidAndNotExpiredCertsWhichArenNotFraud: [ExtendedCBORWebToken] {
        self.filter({ ($0.vaccinationCertificate.isExpired && !$0.vaccinationCertificate.isFraud) || !$0.isInvalid  })
    }
    
    func firstIndex(of certificate: Element?) -> Int? {
        firstIndex {
            $0.vaccinationCertificate.hcert.dgc == certificate?.vaccinationCertificate.hcert.dgc
        }
    }

    func pairableCertificates(for certificate: Element) -> [Element] {
        filter {
            $0.vaccinationCertificate.hcert.dgc == certificate.vaccinationCertificate.hcert.dgc
        }
    }

    func certificatePair(for certificate: Element) -> [Element] {
        if isEmpty {
            return []
        }
        return pairableCertificates(for: certificate)
    }
    
    func filter(types: [CertType],
                       givenName: String,
                       familyName: String,
                       dob: String) -> [ExtendedCBORWebToken] {
        return filter(by: types)
                .filter(by: .givenName, for: givenName)
                .filter(by: .familyName, for: familyName)
                .filter(by: .dateOfBirth, for: dob)
    }
    
    func filter(by types: [CertType]) -> [ExtendedCBORWebToken] {
        var filteredCerts = [ExtendedCBORWebToken]()
        types.forEach { type in
            filteredCerts.append(contentsOf: filter(by: type))
        }
        return filteredCerts
    }
    
    func filter(by type: CertType) -> [ExtendedCBORWebToken] {
        switch type {
        case .recovery:
            return filter {
                $0.firstRecovery != nil
            }
        case .test:
            return filter {
                $0.firstTest != nil
            }
        case .vaccination:
            return filter {
                $0.firstVaccination != nil
            }
        }
    }
    
    func filter(by property: Property, for value: String) -> [ExtendedCBORWebToken] {
        switch property {
        case .givenName:
            return filter{
                $0.givenName?.contains(value) == true
            }
        case .familyName:
            return filter{
                $0.familyName.contains(value) == true
            }
        case .dateOfBirth:
            return filter{
                $0.dateOfBirthString == value
            }.sortByDateOfBirth
        }
    }
    
    var sortLatestPcrTest: [ExtendedCBORWebToken] {
        filterNegativePCRTestsNotOlderThan72Hours
            .sortByIssuedAtTime
            .sortTestsByDateTimeOfSampleCollection
    }
    
    var sortLatestQuickTests: [ExtendedCBORWebToken] {
        filterNegativeQuickTestsNotOlderThan48Hours
            .sortByIssuedAtTime
            .sortTestsByDateTimeOfSampleCollection
    }
    
    var sortLatestBooster: [ExtendedCBORWebToken] {
        filterBoosters
            .sortByIssuedAtTime
            .sortByVaccinationDate
    }
    
    var sortLatestVaccinations: [ExtendedCBORWebToken] {
        filterVaccinations
            .sortByIssuedAtTime
            .sortByVaccinationDate
    }
    
    var sortLatestVaccinationsFirstNotBosstedValidFullImmunization: ExtendedCBORWebToken? {
        sortLatestVaccinations
            .firstNotBosstedValidFullImmunization
    }
    
    var sortLatestVaccinationsFirstNotValidButFullImmunization: ExtendedCBORWebToken? {
        sortLatestVaccinations
            .firstNotValidButFullImmunization
    }
    
    var sortLatestRecoveryWhoseDateIsStillValidSortByFirstPositiveResultDate: [ExtendedCBORWebToken] {
        filterRecoveryWhoseDateIsStillValid
            .sortByFirstPositiveResultDate
    }
    
    var sortLatestNotFullImmunization: [ExtendedCBORWebToken] {
        filterNotFullImmunization
    }
    
    var sortLatestRecoveryWhoseDateNotAnyMoreValidSortByFirstPositiveResultDate: [ExtendedCBORWebToken] {
        filterRecoveryWhoseDateNotAnyMoreValid
            .sortByFirstPositiveResultDate
    }
    
    var sortLatestTestsNegativeAndNotValid: [ExtendedCBORWebToken] {
        filterAllTestsNegativeAndNotValid
    }
    
    func sortLatestRest(_ res: [ExtendedCBORWebToken]) -> [ExtendedCBORWebToken] {
        return filter { !res.contains($0) }
    }
    
    func sortLatest() -> [ExtendedCBORWebToken] {
        var res = [ExtendedCBORWebToken]()
        // #1 Test certificate
        //  Negative PCR Test not older than (=<)72h, ordered by date (newest first)
        res.append(contentsOf: sortLatestPcrTest)
        // #2 Test certificate
        //  Negative quick test, not older than 48 hrs, ordered by date (newest first)
        res.append(contentsOf: sortLatestQuickTests)
        // #3 Booster Certificate
        //  Latest booster vaccination of a vaccination series (3/3, 4/4, ...)
        res.append(contentsOf: sortLatestBooster)
        // #4 Vaccination certificate
        //  Latest vaccination of a vaccination series (1/1, 2/2), older then (>) 14 days, and where the iat is the latest
        if let latestVaccination = sortLatestVaccinationsFirstNotBosstedValidFullImmunization {
            res.append(latestVaccination)
        }
        // #5 Recovery certificate
        //  Recovery after SARS-Cov-2-Infection, not older then (=<) 180 Days
        res.append(contentsOf: sortLatestRecoveryWhoseDateIsStillValidSortByFirstPositiveResultDate)
        // #6 Vaccination Certificate
        //  Latest vaccination of a vaccination series, not older then (=<) 14 days
        if let latestVaccination = sortLatestVaccinationsFirstNotValidButFullImmunization {
            res.append(latestVaccination)
        }
        // #7 Vaccination Certificate
        //  Not-latest (partial immunization) of a vaccination series (1/2)
        res.append(contentsOf: sortLatestNotFullImmunization)
        // #8 Recovery Certificate
        //  Recovery after SARS-Cov-2-Infection, older then (>) 180 Days
        res.append(contentsOf: sortLatestRecoveryWhoseDateNotAnyMoreValidSortByFirstPositiveResultDate)
        // #9 Test certificate
        //  Negative PCR-Test, older then (>) 72 Hrs, or negative quick test older then (>) 48 Hrs
        res.append(contentsOf: sortLatestTestsNegativeAndNotValid)
        // #10 Now add everything that did not match any of the rules above
        res.append(contentsOf: sortLatestRest(res))
        return res
    }
}


private extension ExtendedCBORWebToken {
    func matches(_ extendedCBORWebToken: ExtendedCBORWebToken) -> Bool {
        vaccinationCertificate.hcert.dgc == extendedCBORWebToken.vaccinationCertificate.hcert.dgc
    }
}
