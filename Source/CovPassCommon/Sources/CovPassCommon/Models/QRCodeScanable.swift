//
//  QRCodeScanable.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// For now a proxy protocol as we had only one way for scanning QR Codes which expected to be the Promise an ExtendedCBORWebToken
/// As with VAAS we get a different QR Code and need also a new way in the code to handle this
public protocol QRCodeScanable {}
