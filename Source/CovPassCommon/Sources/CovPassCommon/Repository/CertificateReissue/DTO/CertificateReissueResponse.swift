//
//  CertificateReissueResponse.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

struct CertificateReissueResponse: Codable {
    /// Compressed and Base45 encoded digital green certificate.
    let certificate: String
    /// Array of certificates related to this new certificate indicating the action.
    let relations: [CertificateReissueRelation]
}
