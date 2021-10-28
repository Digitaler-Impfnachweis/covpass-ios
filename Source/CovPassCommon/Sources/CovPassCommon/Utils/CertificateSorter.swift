//
//  CertificateSorter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension ExtendedCBORWebToken {
    
    var tests: [Test]? { vaccinationCertificate.hcert.dgc.t }

    var recoveries: [Recovery]? { vaccinationCertificate.hcert.dgc.r }

    var vaccinations: [Vaccination]? { vaccinationCertificate.hcert.dgc.v }

    var firstTest: Test? { tests?.first }
    
    var firstRecovery: Recovery? { recoveries?.first }
    
    var firstVaccination: Vaccination? { vaccinations?.first }
    
}

extension Array where Element == ExtendedCBORWebToken {
    
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
    
    var filterNegativePCRTestsNotOlderThan72Hours: [ExtendedCBORWebToken] {
        filter {
            if let t = $0.firstTest, t.isPCR, !t.isPositive, Date() <= Calendar.current.date(byAdding: .hour, value: 72, to: t.sc) ?? Date() {
                return true
            }
            return false
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
    
    var filterBoosted: [ExtendedCBORWebToken] {
        filter {
            if let v = $0.firstVaccination, v.isBoosted {
                return true
            }
            return false
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
    
    var firstNotBosstedValidFullImmunization: ExtendedCBORWebToken? {
        first(where: {
            if let v = $0.firstVaccination, v.fullImmunization, v.fullImmunizationValid, !v.isBoosted /* Boosters are currently lower prioritized (see 5.1) */ {
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
}

public enum CertificateSorter {
    /// Sorts the certificates by given order
    public static func sort(_ certificates: [ExtendedCBORWebToken]) -> [ExtendedCBORWebToken] {
        var res = [ExtendedCBORWebToken]()
        // #1 Test certificate
        //  Negative PCR Test not older than (=<)72h, ordered by date (newest first)
        let pcrTests = certificates.filterNegativePCRTestsNotOlderThan72Hours
        res.append(contentsOf: pcrTests.sortByIssuedAtTime.sortTestsByDateTimeOfSampleCollection)
        // #2 Test certificate
        //  Negative quick test, not older than 48 hrs, ordered by date (newest first)
        var quickTests = certificates.filterNegativeQuickTestsNotOlderThan48Hours
        quickTests  = quickTests.sortByIssuedAtTime
        quickTests  = quickTests.sortTestsByDateTimeOfSampleCollection
        res.append(contentsOf: quickTests)
        // #3 Booster Certificate
        //  Latest booster vaccination of a vaccination series (3/3, 4/4, ...)
        res.append(contentsOf: certificates.filterBoosted)
        // #4 Vaccination certificate
        //  Latest vaccination of a vaccination series (1/1, 2/2), older then (>) 14 days, and where the iat is the latest
        let vaccinationCertificates = certificates.filterVaccinations.sortByIssuedAtTime.sortByVaccinationDate
        if let latestVaccination = vaccinationCertificates.firstNotBosstedValidFullImmunization {
            res.append(latestVaccination)
        }
        // #5 Recovery certificate
        //  Recovery after SARS-Cov-2-Infection, not older then (=<) 180 Days
        res.append(contentsOf: certificates.filterRecoveryWhoseDateIsStillValid)
        // #6 Vaccination Certificate
        //  Latest vaccination of a vaccination series, not older then (=<) 14 days
        if let latestVaccination = vaccinationCertificates.firstNotValidButFullImmunization {
            res.append(latestVaccination)
        }
        // #7 Vaccination Certificate
        //  Not-latest (partial immunization) of a vaccination series (1/2)
        res.append(contentsOf: certificates.filterNotFullImmunization)
        // #8 Recovery Certificate
        //  Recovery after SARS-Cov-2-Infection, older then (>) 180 Days
        res.append(contentsOf: certificates.filterRecoveryWhoseDateNotAnyMoreValid)
        // #9 Test certificate
        //  Negative PCR-Test, older then (>) 72 Hrs, or negative quick test older then (>) 48 Hrs
        res.append(contentsOf: certificates.filterAllTestsNegativeAndNotValid)
        // #10 Now add everything that did not match any of the rules above
        res.append(contentsOf: certificates.filter { !res.contains($0) })

        return res
    }
}
