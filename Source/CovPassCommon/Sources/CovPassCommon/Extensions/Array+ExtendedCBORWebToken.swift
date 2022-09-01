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

    var areVaccinationsQualifiedForExpiryReissue: Bool {
        vaccinationExpiryReissueCandidate != nil
    }

    var qualifiedCertificatesForVaccinationExpiryReissue: Self {
        let allCertificatesOrderedByDate = sortedByDtFrAndSc
        guard let reissueCandidate = allCertificatesOrderedByDate.vaccinationExpiryReissueCandidate else {
            return []
        }
        let results = allCertificatesOrderedByDate
            .sixCertificatesExcludingTests(from: reissueCandidate)
        return results
    }

    private var sortedByDtFrAndSc: Self {
        sorted { element1, element2 in
            element1.vaccinationCertificate.dtFrOrSc() > element2.vaccinationCertificate.dtFrOrSc()
        }
    }

    private var vaccinationExpiryReissueCandidate: ExtendedCBORWebToken? {
        guard let latestVaccination = sortLatest().firstVaccination?.vaccinationCertificate,
              latestVaccination.willExpireInLessOrEqual28Days ||
                latestVaccination.expiredForLessOrEqual90Days else {
            return nil
        }
        return filterExpiryReissueCandidates
            .first(where: \.vaccinationCertificate.isVaccination)
    }

    private var filterExpiryReissueCandidates: Self {
        filter {
            let cborToken = $0.vaccinationCertificate
            return cborToken.willExpireInLessOrEqual28Days || cborToken.expiredForLessOrEqual90Days
        }
        .filterIssuedByGerman
        .filter { !$0.isRevoked }
        .filter { !$0.vaccinationCertificate.isTest }
    }

    private func sixCertificatesExcludingTests(from token : ExtendedCBORWebToken) -> Self {
        Array(drop { $0 != token })
            .filter { !$0.vaccinationCertificate.isTest }
            .takeFirst(6)
    }

    var qualifiedCertificatesForRecoveryExpiryReissue: [Self] {
        let allCertificatesOrderedByDate = sortedByDtFrAndSc
        let reissueCandidates = allCertificatesOrderedByDate.recoveryExpiryReissueCandidates
        let results: Array<Self> = reissueCandidates.map { token in
            allCertificatesOrderedByDate
                .sixCertificatesExcludingTests(from: token)
        }
        return results
    }

    private var recoveryExpiryReissueCandidates: [ExtendedCBORWebToken] {
        filterExpiryReissueCandidates
            .filter(\.vaccinationCertificate.isRecovery)
    }

    var reissueProcessInitialNotAlreadySeen: Bool { !reissueProcessInitialAlreadySeen }
    
    var reissueProcessInitialAlreadySeen: Bool { first(where: { $0.reissueProcessInitialAlreadySeen ?? false }) != nil }
    
    var reissueNewBadgeAlreadySeen: Bool { first(where: { $0.reissueProcessNewBadgeAlreadySeen ?? false }) != nil }

    var vaccinationExpiryReissueNewBadgeAlreadySeen: Bool {
        vaccinationExpiryReissueCandidate?.reissueProcessNewBadgeAlreadySeen ?? false
    }

    var tokensOfVaccinationWithSingleDoseFromGermany: [ExtendedCBORWebToken] {
        filter {
            guard let vaccinations = $0.vaccinations else {
                return false
            }
            return !vaccinations.filter{ $0.isSingleDoseComplete }.isEmpty
        }.filterIssuedByGerman
    }
    
    private var cleanVaccinationDuplicates: Self {
        var cleanTokens = [ExtendedCBORWebToken]()
        for token in self.filterVaccinations {
            if cleanTokens.containsSameVaccinationDateAndIsIssuedBefore(token),
                let tokenIndex = cleanTokens.firstIndex(where: {$0.isVaccinatedOnSameDateAndIsIssuedBefore(token)}) {
                cleanTokens[tokenIndex] = token
            } else if cleanTokens.notContainSameVaccinationDate(like: token) {
                cleanTokens.append(token)
            }
        }
        return cleanTokens
    }
    
    private var cleanRecoveryDuplicates: Self {
        var cleanTokens = [ExtendedCBORWebToken]()
        for token in self.filterRecoveries {
            if cleanTokens.containsSameRecoveryTestDateAndIsIssuedBefore(token),
               let tokenIndex = cleanTokens.firstIndex(where: {$0.isTestedForRecoveryOnSameDateAndIsIssuedBefore(token)}) {
                cleanTokens[tokenIndex] = token
            } else if cleanTokens.notContainSameRecoveryTestDate(like: token) {
                cleanTokens.append(token)
            }
        }
        return cleanTokens
    }
    
    private var cleanDateDuplicates: Self {
        var cleanTokens = [ExtendedCBORWebToken]()
        for token in self {
            if cleanTokens.containsSameDate(like: token) {
                if token.vaccinationCertificate.certType == .vaccination,
                    let tokenIndex = cleanTokens.firstIndex(where: {$0.vaccinationCertificate.dtFrOrSc().daysSince(token.vaccinationCertificate.dtFrOrSc()) == 0}) {
                    cleanTokens[tokenIndex] = token
                }
            } else {
                cleanTokens.append(token)
            }
        }
        return cleanTokens
    }
    
    var cleanDuplicates: Self {
        let certs = cleanVaccinationDuplicates + cleanRecoveryDuplicates
        let cleanedList = certs.cleanDateDuplicates + self.filterTests
        return filter { token in cleanedList.contains { token == $0 } }
    }
    
    func notContainSameVaccinationDate(like token: ExtendedCBORWebToken) -> Bool {
        !contains(where:{$0.sameDateVaccination(for: token)})
    }
    
    func containsSameVaccinationDateAndIsIssuedBefore(_ token: ExtendedCBORWebToken) -> Bool {
        contains(where: {$0.isVaccinatedOnSameDateAndIsIssuedBefore(token)})
    }
    
    func notContainSameRecoveryTestDate(like token: ExtendedCBORWebToken) -> Bool {
        !contains(where:{$0.sameRecoveryTestDate(for: token)})
    }
    
    func containsSameRecoveryTestDateAndIsIssuedBefore(_ token: ExtendedCBORWebToken) -> Bool {
        contains(where: {$0.isTestedForRecoveryOnSameDateAndIsIssuedBefore(token)})
    }
    
    func containsSameDate(like token: ExtendedCBORWebToken) -> Bool {
        contains(where: {$0.vaccinationCertificate.dtFrOrSc().daysSince(token.vaccinationCertificate.dtFrOrSc()) == 0 })
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
    
    var filterTests: [ExtendedCBORWebToken] {
        filter { $0.tests != nil }
    }
    
    var firstVaccination: ExtendedCBORWebToken? { first(where:\.vaccinationCertificate.isVaccination) }
    
    var firstRecovery: ExtendedCBORWebToken? { first(where:\.vaccinationCertificate.isRecovery) }
    
    var firstTest: ExtendedCBORWebToken? { first(where:\.vaccinationCertificate.isTest) }
    
    var filterNotInvalid: Self { filter(\.isNotInvalid) }
    
    var filterNotRevoked: Self { filter(\.isNotRevoked) }
    
    var filterNotExpired: Self { filter(\.isNotExpired) }

    var filterFirstOfAllTypes: [ExtendedCBORWebToken] {
        var firstOfAll: [ExtendedCBORWebToken] = []
        let sortedList = sortLatest().filterNotInvalid.filterNotRevoked.filterNotExpired
        if let firstTest = sortedList.firstTest {
            firstOfAll.append(firstTest)
        }
        if let firstVaccination = sortedList.firstVaccination {
            firstOfAll.append(firstVaccination)
        }
        if let firstRecovery = sortedList.firstRecovery {
            firstOfAll.append(firstRecovery)
        }
        return firstOfAll
    }
    
    var vaccinations: [Vaccination] {
        filterVaccinations.map{ $0.vaccinations }.compactMap{$0}.flatMap{$0}
    }
    
    var recoveries: [Recovery] {
        filterRecoveries.map{ $0.recoveries }.compactMap{$0}.flatMap{$0}
    }
    
    var firstNotBoostedValidFullImmunization: ExtendedCBORWebToken? {
        first(where: {
            guard $0.isNotRevoked, $0.isNotExpired, $0.isNotInvalid, let v = $0.firstVaccination else {
                return false
            }
            return v.fullImmunization && v.fullImmunizationValid && !v.isBoosted(vaccinations: vaccinations, recoveries: recoveries)
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

    func filter(by name: Name, dateOfBirth: Date?) -> Self {
        filter {
            let dgc = $0.vaccinationCertificate.hcert.dgc
            return dgc.nam == name && dgc.dob == dateOfBirth
        }
    }
    
    var sortLatestPcrTest: [ExtendedCBORWebToken] {
        filterNegativePCRTestsNotOlderThan72Hours
            .filterNotInvalid.filterNotRevoked.filterNotExpired
            .sortByIssuedAtTime
            .sortTestsByDateTimeOfSampleCollection
    }
    
    var sortLatestQuickTests: [ExtendedCBORWebToken] {
        filterNegativeQuickTestsNotOlderThan48Hours
            .filterNotInvalid.filterNotRevoked.filterNotExpired
            .sortByIssuedAtTime
            .sortTestsByDateTimeOfSampleCollection
    }
    
    var sortLatestBooster: [ExtendedCBORWebToken] {
        filterBoosters
            .filterNotInvalid.filterNotRevoked.filterNotExpired
            .sortByIssuedAtTime
            .sortByVaccinationDate
    }
    
    var sortLatestVaccinations: [ExtendedCBORWebToken] {
        filterVaccinations
            .sortByIssuedAtTime
            .sortByVaccinationDate
    }
    
    var sortLatestVaccinationsfirstNotBoostedValidFullImmunization: ExtendedCBORWebToken? {
        sortLatestVaccinations
            .firstNotBoostedValidFullImmunization
    }
    
    var sortLatestVaccinationsFirstNotValidButFullImmunization: ExtendedCBORWebToken? {
        sortLatestVaccinations
            .filterNotInvalid.filterNotRevoked.filterNotExpired
            .firstNotValidButFullImmunization
    }
    
    var sortLatestRecoveryWhoseDateIsStillValidSortByFirstPositiveResultDate: [ExtendedCBORWebToken] {
        filterRecoveryWhoseDateIsStillValid
            .filterNotInvalid.filterNotRevoked.filterNotExpired
            .sortByFirstPositiveResultDate
    }
    
    var sortLatestNotFullImmunization: [ExtendedCBORWebToken] {
        filterNotFullImmunization
            .filterNotInvalid.filterNotRevoked.filterNotExpired
            .sortByIssuedAtTime
            .sortByVaccinationDate
    }
    
    var sortLatestRecoveryWhoseDateNotAnyMoreValidSortByFirstPositiveResultDate: [ExtendedCBORWebToken] {
        filterRecoveryWhoseDateNotAnyMoreValid
            .filterNotInvalid.filterNotRevoked.filterNotExpired
            .sortByFirstPositiveResultDate
    }
    
    var sortLatestTestsNegativeAndNotValid: [ExtendedCBORWebToken] {
        filterAllTestsNegativeAndNotValid
            .filterNotInvalid.filterNotRevoked.filterNotExpired
    }
    
    func sortLatestRest(_ res: [ExtendedCBORWebToken]) -> [ExtendedCBORWebToken] {
        return filter { !res.contains($0) }.sortedByDtFrAndSc
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
        if let latestVaccination = sortLatestVaccinationsfirstNotBoostedValidFullImmunization {
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

private extension CBORWebToken {
    func dtFrOrSc() -> Date {
        let date: Date
        if let vaccination = hcert.dgc.v?.first {
            date = vaccination.dt
        } else if let recovery = hcert.dgc.r?.first {
            date = recovery.fr
        } else if let test = hcert.dgc.t?.first {
            date = test.sc
        } else {
            date = .init(timeIntervalSinceReferenceDate: 0)
        }
        return date
    }
}
