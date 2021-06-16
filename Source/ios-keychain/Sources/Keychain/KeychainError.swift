//
//  KeychainError.swift
//
//
//  Created by Daniel Mandea on 05/04/2020.
//

import Foundation

public enum KeychainError: Error {
    case store
    case delete
    case fetch
}
