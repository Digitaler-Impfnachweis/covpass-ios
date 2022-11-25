//
//  DigitalGreenCertificateExtension.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension DigitalGreenCertificate: Equatable {
    public static func == (lhs: DigitalGreenCertificate, rhs: DigitalGreenCertificate) -> Bool {
        lhs.nam == rhs.nam && lhs.dob == rhs.dob
    }
}

public extension DigitalGreenCertificate {
    var fullImmunizationValid: Bool {
        guard let result = v?.filter(\.fullImmunizationValid) else { return false }
        return !result.isEmpty
    }

    var isPCR: Bool {
        guard let result = t?.filter(\.isPCR) else { return false }
        return !result.isEmpty
    }

    var isSingleDoseComplete: Bool {
        guard let result = v?.filter(\.isSingleDoseComplete) else { return false }
        return !result.isEmpty
    }

    var isDoubleDoseComplete: Bool {
        guard let result = v?.filter(\.isDoubleDoseComplete) else { return false }
        return !result.isEmpty
    }

    var isJohnsonJohnson: Bool {
        guard let result = v?.filter(\.isJohnsonJohnson) else { return false }
        return !result.isEmpty
    }

    var isModerna: Bool {
        guard let result = v?.filter(\.isModerna) else { return false }
        return !result.isEmpty
    }

    var isBiontech: Bool {
        guard let result = v?.filter(\.isBiontech) else { return false }
        return !result.isEmpty
    }

    var isAstrazeneca: Bool {
        guard let result = v?.filter(\.isAstrazeneca) else { return false }
        return !result.isEmpty
    }

    var is1of2Vaccination: Bool {
        guard let vaccinations = v else { return false }
        let result = vaccinations.contains { vaccination in
            vaccination.dn == 1 && vaccination.sd == 2
        }
        return result
    }

    var isJohnsonAndJohnson2of2Vaccination: Bool {
        v?.contains { $0.isJohnsonJohnson && $0.isDoubleDoseComplete } ?? false
    }
}

public extension Array where Element == DigitalGreenCertificate {
    /// Combine multiple certifcates into one
    func joinCertificates(latestOnly: Bool = true) -> Element? {
        guard var baseCertificate = first else {
            return nil
        }
        baseCertificate.v = []
        baseCertificate.t = []
        baseCertificate.r = []

        let vaccinations = compactMap(\.v).flatMap { $0 }.sortByLatestDt
        let recoveries = compactMap(\.r).flatMap { $0 }.sortByLatestFr
        let tests = compactMap(\.t).flatMap { $0 }.sortByLatestSc

        if let latestVaccination = vaccinations.latestVaccination, latestOnly {
            baseCertificate.v = vaccinations.isEmpty ? nil : [latestVaccination]
        } else {
            baseCertificate.v?.append(contentsOf: vaccinations)
        }
        if let latestRecovery = recoveries.latestRecovery, latestOnly {
            baseCertificate.r = recoveries.isEmpty ? nil : [latestRecovery]
        } else {
            baseCertificate.r?.append(contentsOf: recoveries)
        }
        if let latestTest = tests.latestTest, latestOnly {
            baseCertificate.t = tests.isEmpty ? nil : [latestTest]
        } else {
            baseCertificate.t?.append(contentsOf: tests)
        }

        if baseCertificate.v?.isEmpty ?? true {
            baseCertificate.v = nil
        }
        if baseCertificate.r?.isEmpty ?? true {
            baseCertificate.r = nil
        }
        if baseCertificate.t?.isEmpty ?? true {
            baseCertificate.t = nil
        }

        return baseCertificate
    }
}
