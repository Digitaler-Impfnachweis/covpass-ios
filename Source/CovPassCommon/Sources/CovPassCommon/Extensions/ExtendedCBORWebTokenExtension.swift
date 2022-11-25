//
//  ExtendedCBORWebTokenExtension.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension ExtendedCBORWebToken {
    var tests: [Test]? { vaccinationCertificate.hcert.dgc.t }

    var recoveries: [Recovery]? { vaccinationCertificate.hcert.dgc.r }

    var vaccinations: [Vaccination]? { vaccinationCertificate.hcert.dgc.v }

    var givenName: String? { vaccinationCertificate.hcert.dgc.nam.gnt }

    var familyName: String { vaccinationCertificate.hcert.dgc.nam.fnt }

    var dateOfBirthString: String? { vaccinationCertificate.hcert.dgc.dobString }

    var dateOfBirth: Date? { vaccinationCertificate.hcert.dgc.dob }

    var firstTest: Test? { tests?.first }

    var firstRecovery: Recovery? { recoveries?.first }

    var firstVaccination: Vaccination? { vaccinations?.first }

    var canExportToPDF: Bool { vaccinationCertificate.hcert.dgc.template != nil }

    var isInvalid: Bool { invalid ?? false }

    var isNotInvalid: Bool { !isInvalid }

    var isRevoked: Bool { revoked ?? false }

    var isNotRevoked: Bool { !isRevoked }

    var isNotExpired: Bool { !vaccinationCertificate.isExpired }

    func sameDateVaccination(for token: ExtendedCBORWebToken) -> Bool {
        guard let dt1 = firstVaccination?.dt else {
            return false
        }
        guard let dt2 = token.firstVaccination?.dt else {
            return false
        }
        return dt1.daysSince(dt2) == 0
    }

    func sameRecoveryTestDate(for token: ExtendedCBORWebToken) -> Bool {
        guard let fr1 = firstRecovery?.fr else {
            return false
        }
        guard let fr2 = token.firstRecovery?.fr else {
            return false
        }
        return fr1.daysSince(fr2) == 0
    }

    func issuedBefore(for token: ExtendedCBORWebToken) -> Bool {
        guard let iat1 = vaccinationCertificate.iat else {
            return false
        }
        guard let iat2 = token.vaccinationCertificate.iat else {
            return false
        }
        return iat1 < iat2
    }

    func isVaccinatedOnSameDateAndIsIssuedBefore(_ token: ExtendedCBORWebToken) -> Bool {
        sameDateVaccination(for: token) && issuedBefore(for: token)
    }

    func isTestedForRecoveryOnSameDateAndIsIssuedBefore(_ token: ExtendedCBORWebToken) -> Bool {
        sameRecoveryTestDate(for: token) && issuedBefore(for: token)
    }

    var expiryAlertWasNotShown: Bool {
        let wasAlreadyShown = wasExpiryAlertShown ?? false
        return !wasAlreadyShown
    }

    var dtFrOrSc: Date {
        let date: Date
        if let vaccination = vaccinationCertificate.hcert.dgc.v?.first {
            date = vaccination.dt
        } else if let recovery = vaccinationCertificate.hcert.dgc.r?.first {
            date = recovery.fr
        } else if let test = vaccinationCertificate.hcert.dgc.t?.first {
            date = test.sc
        } else {
            date = .init(timeIntervalSinceReferenceDate: 0)
        }
        return date
    }
}
