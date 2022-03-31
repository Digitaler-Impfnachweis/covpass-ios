//
//  CertificateReissueRepositoryError.swift
//  
//
//  Created by Thomas Kuleßa on 16.03.22.
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
