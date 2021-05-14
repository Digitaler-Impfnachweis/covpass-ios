//
//  FontLoadingError.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public enum FontLoadingError: Error {
    case registration
    case other(String)
}
