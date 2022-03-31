//
//  CBORWebTokenExtension.swift
//  
//
//  Created by Fatih Karakurt on 25.02.22.
//

import Foundation

public extension CBORWebToken {
    
    var isFraud: Bool {
        guard let locationHash = hcert.dgc.uvciLocationHash else {
            return false
        }
        let isFraud = VaccinationRepository.entityBlacklist.contains(locationHash)
        return isFraud
    }
    
    var isVaccination: Bool {
        hcert.dgc.v?.isEmpty == false
    }
    
    var isNotVaccination: Bool {
        !isVaccination
    }
    
    var isRecovery: Bool {
        hcert.dgc.r?.isEmpty == false
    }
    
    var isNotRecovery: Bool {
       !isRecovery
    }
    
    var isTest: Bool {
        hcert.dgc.t?.isEmpty == false
    }
    
    var isNotTest: Bool {
       !isTest
    }
    
    var certType: CertType {
        isTest ? .test : isRecovery ? .recovery : .vaccination
    }
    
}
