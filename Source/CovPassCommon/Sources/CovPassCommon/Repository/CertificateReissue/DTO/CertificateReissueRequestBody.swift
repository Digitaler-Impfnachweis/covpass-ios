//
//  CertificateReissueRequestBody.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

/// HTTP request body for the remote certificate reissue API. The body contains a list of valid Digital Green
/// Certificate(s) (DGC) signed in Germany (DE) that are needed for re-issue.
/// See [API specification](https://github.com/Digitaler-Impfnachweis/certification-apis/blob/master/dcc-reissue-api.yaml).
struct CertificateReissueRequestBody: Codable {
    /// The operation to execute on the input certificate(s). All certificates in a single request must adhere
    /// to same-person rule. Each request operates on certificates of one person.
    let action: Action
    /// One or more compressed and Base45 encoded digital green certificates required for the operation.
    let certificates: [String]

    enum Action: String, Codable {
        case renew
        case extend
        case combine
    }
}
