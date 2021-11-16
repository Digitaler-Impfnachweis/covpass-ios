//
//  File.swift
//  
//
//  Created by Andreas Kostuch on 12.11.21.
//

import Foundation
import PromiseKit

public protocol VAASRepositoryProtocol {
    mutating func decodeInitialisationQRCode(payload: String) -> ValidationServiceInitialisation?
    func fetchValidationService() -> Promise<Void>
}

public struct VAASRepository: VAASRepositoryProtocol {
    
    private let service: APIServiceProtocol
    private var ticket: ValidationServiceInitialisation
    
    public init(service: APIServiceProtocol, ticket: ValidationServiceInitialisation) {
        self.service = service
        self.ticket = ticket
    }
    
    private func identityDocument(identityString: String) -> Promise<IdentityDocument> {
        Promise { seal in
            seal.fulfill(try! JSONDecoder().decode(IdentityDocument.self, from: identityString.data(using: .utf8)!))
        }
    }
    
    public func fetchValidationService() -> Promise<Void> {
        firstly {
            service.vaasListOfServices(initialisationData: ticket)
        }
        .map{ stringResponse in
            identityDocument(identityString: stringResponse)
        }
        .map { identityDocument in
            // HERE WE GO
        }
    }
    
    public mutating func decodeInitialisationQRCode(payload: String) -> ValidationServiceInitialisation? {
        guard let data = payload.data(using: .utf8),
              let ticket = try? JSONDecoder().decode(ValidationServiceInitialisation.self, from: data) else {
                  return nil
              }
        self.ticket = ticket
        return ticket
    }
}
