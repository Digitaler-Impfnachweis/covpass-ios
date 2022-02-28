//
//  File.swift
//  
//
//  Created by Thomas Kuleßa on 28.02.22.
//

import Foundation
import PromiseKit

extension CoseSign1Message {
    static func promise(data: Data) -> Promise<Self> {
        do {
            let message = try CoseSign1Message(decompressedPayload: data)
            return .value(message)
        } catch  {
            return .init(error: error)
        }
    }
}
