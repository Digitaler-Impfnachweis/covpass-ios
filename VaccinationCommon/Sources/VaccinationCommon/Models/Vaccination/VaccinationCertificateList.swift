//
//  VaccinationCertificateList.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public struct VaccinationCertificateList {
    var certificates: [ExtendedVaccinationCertificate]
    var favoriteCertificateId: String?

    public init(certificates: [ExtendedVaccinationCertificate], favoriteCertificateId: String? = nil) {
        self.certificates = certificates
        self.favoriteCertificateId = favoriteCertificateId
    }
}
