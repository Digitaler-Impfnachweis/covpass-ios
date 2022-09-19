//
//  DigitalGreenCertificateExtension.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension DigitalGreenCertificate: Equatable {
    public static func == (lhs: DigitalGreenCertificate, rhs: DigitalGreenCertificate) -> Bool {
        return lhs.nam == rhs.nam && lhs.dob == rhs.dob
    }
}

public extension DigitalGreenCertificate {
    var fullImmunizationValid: Bool {
        guard let result = v?.filter({ $0.fullImmunizationValid }) else { return false }
        return !result.isEmpty
    }
    
    var isPCR: Bool {
        guard let result = t?.filter({ $0.isPCR }) else { return false }
        return !result.isEmpty
    }
    
    var isSingleDoseComplete: Bool {
        guard let result = v?.filter({ $0.isSingleDoseComplete }) else { return false }
        return !result.isEmpty
    }
    
    var isDoubleDoseComplete: Bool {
        guard let result = v?.filter({ $0.isDoubleDoseComplete }) else { return false }
        return !result.isEmpty
    }
    
    var isJohnsonJohnson: Bool {
        guard let result = v?.filter({ $0.isJohnsonJohnson }) else { return false }
        return !result.isEmpty
    }
    
    var isModerna: Bool {
        guard let result = v?.filter({ $0.isModerna }) else { return false }
        return !result.isEmpty
    }
    
    var isBiontech: Bool {
        guard let result = v?.filter({ $0.isBiontech }) else { return false }
        return !result.isEmpty
    }
    
    var isAstrazeneca: Bool {
        guard let result = v?.filter({ $0.isAstrazeneca }) else { return false }
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
    /// Combine multiple certifcates into one, when all have matching names and date of birth.
    func joinCertificates() -> Element? {
        let certificatesWithoutFirst = Array(dropFirst())
        guard var baseCertificate = first,
              certificatesWithoutFirst.allSatisfy({ $0 == baseCertificate })
        else {
            return nil
        }
        let vaccinations = compactMap { $0.v }.flatMap { $0 }
        let recoveries = compactMap { $0.r }.flatMap { $0 }
        let tests = compactMap { $0.t }.flatMap { $0 }

        if let latestVaccination = vaccinations.latestVaccination {
            baseCertificate.v = vaccinations.isEmpty ? nil : [latestVaccination]
        }
        if let latestRecovery = recoveries.latestRecovery {
            baseCertificate.r = recoveries.isEmpty ? nil : [latestRecovery]
        }
        if let latestTest = tests.latestTest {
            baseCertificate.t = tests.isEmpty ? nil : [latestTest]
        }

        return baseCertificate
    }
}
