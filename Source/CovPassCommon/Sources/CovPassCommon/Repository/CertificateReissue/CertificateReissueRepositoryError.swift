//
//  CertificateReissueRepositoryError.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public class CertificateReissueRepositoryError: Error, Equatable {
    public let errorID: String
    public let message: String?

    public init(_ errorID: String, message: String?) {
        self.errorID = errorID
        self.message = message
    }

    public static func == (lhs: CertificateReissueRepositoryError, rhs: CertificateReissueRepositoryError) -> Bool {
        lhs.errorID == rhs.errorID
    }
}

public class CertificateReissueRepositoryFallbackError: CertificateReissueRepositoryError {
    public init() {
        super.init("R000", message: nil)
    }
}
