//
//  ApplicationError.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public enum ApplicationError: Error, ErrorCode {
    case unknownError
    case general(String)
    case missingData(String)

    public var errorCode: Int {
        switch self {
        case .unknownError:
            return 901
        case .general:
            return 902
        case .missingData:
            return 903
        }
    }
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

class PromiseCancelledError: CancellableError {
    var isCancelled: Bool {
        return true
    }
}
