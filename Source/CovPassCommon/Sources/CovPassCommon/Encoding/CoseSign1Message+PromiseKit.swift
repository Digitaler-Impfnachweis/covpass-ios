//
//  File.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

extension CoseSign1Message {
    static func promise(data: Data) -> Promise<Self> {
        do {
            let message = try CoseSign1Message(decompressedPayload: data)
            return .value(message)
        } catch {
            return .init(error: error)
        }
    }
}
