//
//  APIService.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import SwiftCBOR

public struct APIService: APIServiceProtocol {
    private let url: String
    private let contentType: String = "application/cbor+base45"

    private let coder = Base45Coder()
    private let sessionDelegate: URLSessionDelegate

    public init(sessionDelegate: URLSessionDelegate, url: String) {
        self.sessionDelegate = sessionDelegate
        self.url = url
    }
}
