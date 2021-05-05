//
//  VaccinationCertificateList.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public struct VaccinationCertificateList: Codable {
    public var certificates: [ExtendedCBORWebToken]
    public var favoriteCertificateId: String?

    public init(certificates: [ExtendedCBORWebToken], favoriteCertificateId: String? = nil) {
        self.certificates = certificates
        self.favoriteCertificateId = favoriteCertificateId
    }
}
