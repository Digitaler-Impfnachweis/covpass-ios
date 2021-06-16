//
//  TrustList.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct TrustList: Codable {
    public var certificates: [TrustCertificate]
}
