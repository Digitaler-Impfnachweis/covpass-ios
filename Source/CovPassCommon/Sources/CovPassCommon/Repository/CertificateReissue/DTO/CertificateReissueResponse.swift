//
//  CertificateReissueResponse.swift
//  
//
//  Created by Thomas Kuleßa on 17.02.22.
//

struct CertificateReissueResponse: Codable {
    /// Compressed and Base45 encoded digital green certificate.
    let certificate: String
    /// Array of certificates related to this new certificate indicating the action.
    let relations: [CertificateReissueRelation]
}
