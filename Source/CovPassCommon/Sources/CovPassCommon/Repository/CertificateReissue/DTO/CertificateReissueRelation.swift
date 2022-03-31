//
//  CertificateReissueRelation.swift
//  
//
//  Created by Thomas Kuleßa on 17.02.22.
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
