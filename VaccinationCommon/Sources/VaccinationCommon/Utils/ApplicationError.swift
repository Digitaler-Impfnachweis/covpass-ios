//
//  ApplicationError.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public enum ApplicationError: Error {
    case unknownError
    case general(String)
    case missingData(String)
}

extension ApplicationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknownError:
            return NSLocalizedString("UnexpectedError", comment: "UnexpectedError")
        case let .general(value):
            return "\(NSLocalizedString("UnexpectedError", comment: "UnexpectedError"))\n\(value)"
        case let .missingData(value):
            return "\(NSLocalizedString("UnexpectedError", comment: "UnexpectedError"))\nMissing Object: \(value)"
        }
    }
}

extension ApplicationError: Equatable {
    public static func == (lhs: ApplicationError, rhs: ApplicationError) -> Bool {
        if lhs.localizedDescription == rhs.localizedDescription { return true }
        return false
    }
}
