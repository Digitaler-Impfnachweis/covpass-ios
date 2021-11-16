//
//  File.swift
//  
//
//  Created by Andreas Kostuch on 12.11.21.
//

import Foundation
import MapKit

public protocol VAASRepositoryProtocol {
    func decodeInitialisationQRCode(payload: String) -> ValidationServiceInitialisation?
}

public extension VAASRepositoryProtocol {
    func decodeInitialisationQRCode(payload: String) -> ValidationServiceInitialisation? {
        guard let data = payload.data(using: .utf8),
            let ticket = try? JSONDecoder().decode(ValidationServiceInitialisation.self, from: data) else {
                return nil
        }
        return ticket
    }
}

public struct VAASRepository: VAASRepositoryProtocol {
    public init() {}
}
