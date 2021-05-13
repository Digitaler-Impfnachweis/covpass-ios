//
//  APIService.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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
