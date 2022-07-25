//
//  CertificateRevocationDataSourceError.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

enum CertificateRevocationDataSourceError: Error {
    /// CBOR parsing failed.
    case cbor

    /// The resource couldn't be found.
    case notFound

    /// Problem with the response from the origin of data.
    case response

    /// The API method is not supported by the implementation.
    case unsupported
}
