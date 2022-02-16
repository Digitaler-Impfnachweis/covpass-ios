//
//  ExtendedCBORWebToken.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public enum CertType: String {
    case recovery = "r", test = "t", vaccination = "v"
}

public enum Property {
    case givenName, familyName, dateOfBirth
}

public struct ExtendedCBORWebToken: Codable, QRCodeScanable {

    /// CBOR web token vaccination certificate
    public var vaccinationCertificate: CBORWebToken

    /// Raw QRCode data of the cbor web token vaccination certificate
    public var vaccinationQRCodeData: String

    public var wasExpiryAlertShown: Bool?

    public init(vaccinationCertificate: CBORWebToken, vaccinationQRCodeData: String) {
        self.vaccinationCertificate = vaccinationCertificate
        self.vaccinationQRCodeData = vaccinationQRCodeData
    }
}

extension ExtendedCBORWebToken: Equatable {
    public static func == (lhs: ExtendedCBORWebToken, rhs: ExtendedCBORWebToken) -> Bool {
        return lhs.vaccinationQRCodeData == rhs.vaccinationQRCodeData
    }
}

extension ExtendedCBORWebToken: Comparable {
    /// Sort by dose number of first vaccination, result date of first test or valid until date of first recovery
    public static func < (lhs: ExtendedCBORWebToken, rhs: ExtendedCBORWebToken) -> Bool {
        lhs.vaccinationCertificate.hcert.dgc.v?.first?.dn ?? 0 > rhs.vaccinationCertificate.hcert.dgc.v?.first?.dn ?? 0 ||
            lhs.vaccinationCertificate.hcert.dgc.t?.first?.sc ?? Date() > rhs.vaccinationCertificate.hcert.dgc.t?.first?.sc ?? Date() ||
            lhs.vaccinationCertificate.hcert.dgc.r?.first?.du ?? Date() > rhs.vaccinationCertificate.hcert.dgc.r?.first?.du ?? Date()
    }
}

extension ExtendedCBORWebToken {
    
    public var tests: [Test]? { vaccinationCertificate.hcert.dgc.t }

    public var recoveries: [Recovery]? { vaccinationCertificate.hcert.dgc.r }

    public var vaccinations: [Vaccination]? { vaccinationCertificate.hcert.dgc.v }
    
    public var givenName: String? { vaccinationCertificate.hcert.dgc.nam.gnt }
    
    public var familyName: String { vaccinationCertificate.hcert.dgc.nam.fnt }
    
    public var dateOfBirthString: String? { vaccinationCertificate.hcert.dgc.dobString }
   
    public var dateOfBirth: Date? { vaccinationCertificate.hcert.dgc.dob }

    public var firstTest: Test? { tests?.first }
    
    public var firstRecovery: Recovery? { recoveries?.first }
    
    public var firstVaccination: Vaccination? { vaccinations?.first }
    
}

extension Array where Element == ExtendedCBORWebToken {

    public func filter(types: [CertType],
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
    
    public func sortLatest() -> [ExtendedCBORWebToken] {
        var res = [ExtendedCBORWebToken]()
        // #1 Test certificate
        //  Negative PCR Test not older than (=<)72h, ordered by date (newest first)
        let pcrTests = filterNegativePCRTestsNotOlderThan72Hours
        res.append(contentsOf: pcrTests.sortByIssuedAtTime.sortTestsByDateTimeOfSampleCollection)
        // #2 Test certificate
        //  Negative quick test, not older than 48 hrs, ordered by date (newest first)
        var quickTests = filterNegativeQuickTestsNotOlderThan48Hours
        quickTests  = quickTests.sortByIssuedAtTime
        quickTests  = quickTests.sortTestsByDateTimeOfSampleCollection
        res.append(contentsOf: quickTests)
        // #3 Booster Certificate
        //  Latest booster vaccination of a vaccination series (3/3, 4/4, ...)
        res.append(contentsOf: filterBoosted.sortedByDn)
        // #4 Vaccination certificate
        //  Latest vaccination of a vaccination series (1/1, 2/2), older then (>) 14 days, and where the iat is the latest
        let vaccinationCertificates = filterVaccinations.sortByIssuedAtTime.sortByVaccinationDate
        if let latestVaccination = vaccinationCertificates.firstNotBosstedValidFullImmunization {
            res.append(latestVaccination)
        }
        // #5 Recovery certificate
        //  Recovery after SARS-Cov-2-Infection, not older then (=<) 180 Days
        res.append(contentsOf: filterRecoveryWhoseDateIsStillValid)
        // #6 Vaccination Certificate
        //  Latest vaccination of a vaccination series, not older then (=<) 14 days
        if let latestVaccination = vaccinationCertificates.firstNotValidButFullImmunization {
            res.append(latestVaccination)
        }
        // #7 Vaccination Certificate
        //  Not-latest (partial immunization) of a vaccination series (1/2)
        res.append(contentsOf: filterNotFullImmunization)
        // #8 Recovery Certificate
        //  Recovery after SARS-Cov-2-Infection, older then (>) 180 Days
        res.append(contentsOf: filterRecoveryWhoseDateNotAnyMoreValid)
        // #9 Test certificate
        //  Negative PCR-Test, older then (>) 72 Hrs, or negative quick test older then (>) 48 Hrs
        res.append(contentsOf: filterAllTestsNegativeAndNotValid)
        // #10 Now add everything that did not match any of the rules above
        res.append(contentsOf: filter { !res.contains($0) })

        return res
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

    private var sortedByDn: [ExtendedCBORWebToken] {
        sorted { token1, token2 in
            if let vaccination1 = token1.vaccinationCertificate.hcert.dgc.v?.first,
               let vaccination2 = token2.vaccinationCertificate.hcert.dgc.v?.first {
                return vaccination1 < vaccination2
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
    
    public var filterValidAndNotExpiredCertsWhichArenNotFraud: [ExtendedCBORWebToken] {
        self.filter({ ($0.vaccinationCertificate.isExpired && !$0.vaccinationCertificate.isFraud) || !$0.vaccinationCertificate.isInvalid  })
    }
}

public extension ExtendedCBORWebToken {
    /// Checks if a certificate in the given token can be exported to PDF
    ///
    /// If multiple certificates are present the priotization is as follows (most to least important):
    /// 1. vaccination
    /// 2. test
    /// 3. recovery
    var canExportToPDF: Bool {
        vaccinationCertificate.hcert.dgc.template != nil
    }
}
