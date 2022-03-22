//
//  CertificateReissueResponseError.swift
//  
//
//  Created by Thomas Kuleßa on 16.03.22.
//

/// Error returned by the certificate reissue API.
struct CertificateReissueResponseError: Codable {
    let error: String
    let message: String
}
