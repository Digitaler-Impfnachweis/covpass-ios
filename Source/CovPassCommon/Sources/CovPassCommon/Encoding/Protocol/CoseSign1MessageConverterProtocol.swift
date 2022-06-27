//
//  CoseSign1MessageConverterProtocol.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit

/// Protocol for classes/structs which are capable to verify and convert a encoded certificate, like it is used
///  in the digital Covid certificate QQ codes or the by the remote reissue API to an
///  `ExtendedCBORWebToken`.
public protocol CoseSign1MessageConverterProtocol {
    /// Extracts from a string containing a Base45 encoded, compressed and signed CoseSign1Message
    /// the CBOR web token containing a certificate.
    /// - Parameter message: CoseSign1Message e.g. from a QR code or the response from the
    /// remote reissue API.
    /// - Returns: A certificate, if the input could be decoded, decompressed and succeeds in the
    /// signature check.
    func convert(message: String) -> Promise<ExtendedCBORWebToken>
}
