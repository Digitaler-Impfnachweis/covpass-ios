//
//  DigitalGreenCertificateExtension.swift
//  
//
//  Created by Fatih Karakurt on 25.02.22.
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

    var personIsYoungerThan18: Bool { personIsYounger(than: 18) }

    private func personIsYounger(than years: Int) -> Bool {
        guard let dob = dob else { return false }
        let isYounger = Date().yearsSince(dob) < years
        return isYounger
    }

    var is1of2Vaccination: Bool {
        guard let vaccinations = v else { return false }
        let result = vaccinations.contains { vaccination in
            vaccination.dn == 1 && vaccination.sd == 2
        }
        return result
    }
 }
