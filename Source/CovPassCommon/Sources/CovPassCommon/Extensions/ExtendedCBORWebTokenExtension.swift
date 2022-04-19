//
//  ExtendedCBORWebTokenExtension.swift
//  
//
//  Created by Fatih Karakurt on 24.02.22.
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

    var isRevoked: Bool { revoked ?? false  }
    
    var isNotRevoked: Bool { !isRevoked }
}
