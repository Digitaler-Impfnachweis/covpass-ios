//
//  CertificateReissueResponseError.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

/// Error returned by the certificate reissue API.
struct CertificateReissueResponseError: Codable {
    let error: String
    let message: String
}
