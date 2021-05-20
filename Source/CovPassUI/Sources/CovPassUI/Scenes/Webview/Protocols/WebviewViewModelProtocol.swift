//
//  WebviewViewModelProtocol.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public protocol WebviewViewModelProtocol {
    var title: String? { get }
    var urlRequest: URLRequest { get }
    var closeButtonShown: Bool { get set}
}
