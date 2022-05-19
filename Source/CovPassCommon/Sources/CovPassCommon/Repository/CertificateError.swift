//
//  CertificateError.swift
//  
//
//  Created by Thomas Kuleßa on 11.04.22.
//

import Foundation

public enum CertificateError: Error, ErrorCode, Equatable {
    case positiveResult
    case expiredCertifcate
    case invalidEntity
    case revoked(_ token: ExtendedCBORWebToken)

    public var errorCode: Int {
        switch self {
        case .positiveResult:
            return 421
        case .expiredCertifcate:
            return 422
        case .invalidEntity:
            return 423
        case .revoked:
            return 424
        }
    }
}
