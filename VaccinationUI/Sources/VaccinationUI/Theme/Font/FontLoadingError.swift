//
//  FontLoadingError.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public enum FontLoadingError: Error {
    case registration
    case other(String)
}
