//
//  APIError.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public enum APIError: Error {
    case requestCancelled
    case compressionFailed
    case invalidUrl
    case invalidReponse
}
