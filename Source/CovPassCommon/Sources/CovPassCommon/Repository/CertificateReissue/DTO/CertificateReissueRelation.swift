//
//  CertificateReissueRelation.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

/// Relation of a response certificate to a certificate from reissue request  and their related action.
/// See [API specification](https://github.com/Digitaler-Impfnachweis/certification-apis/blob/master/dcc-reissue-api.yaml).
struct CertificateReissueRelation: Codable {
    /// The index of the related certificate from the request.
    let index: Int
    /// The operational relation to the new certificate.
    let action: Action

    enum Action: String, Codable {
        case extend
        case nop
        case replace
    }
}
