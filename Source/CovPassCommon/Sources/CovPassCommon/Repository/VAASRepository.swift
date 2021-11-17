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

public class VAASRepository: VAASRepositoryProtocol {
    
    private let service: APIServiceProtocol
    private var ticket: ValidationServiceInitialisation
    var identityDocumentDecorator: IdentityDocument?
    
    public init(service: APIServiceProtocol, ticket: ValidationServiceInitialisation) {
        self.service = service
        self.ticket = ticket
    }

    private func identityDocument(identityString: String) throws -> Promise<IdentityDocument> {
        Promise { seal in
            seal.fulfill(try JSONDecoder().decode(IdentityDocument.self, from: identityString.data(using: .utf8)!))
        }
    }
    
    public func fetchValidationService() -> Promise<Void> {
        firstly {
            service.vaasListOfServices(initialisationData: ticket)
        }
        .then { stringResponse in
            try self.identityDocument(identityString: stringResponse)
        }
        .then { identityDocument -> Promise<String> in
            // HERE WE GO
            let serverListInfo = identityDocument
            self.identityDocumentDecorator = identityDocument
            guard var services = serverListInfo.service else { throw APIError.invalidResponse }
            services[0].isSelected = true
            guard let service = services.filter({ $0.isSelected ?? false }).first else {  throw APIError.invalidResponse }
            guard let serviceURL = URL(string: service.serviceEndpoint)  else {  throw APIError.invalidResponse }
            return self.service.vaasListOfServices(url: serviceURL)
        }
        .then { stringResponse -> Promise<IdentityDocument> in
            return try self.identityDocument(identityString: stringResponse)
        }
        .then { identityDocument -> Promise<Void> in
            guard let services = identityDocument.service?.filter({ $0.isSelected ?? false }) else {  throw APIError.invalidResponse }
            guard let accessTokenService = services.first(where: { $0.type == "AccessTokenService" }) else {  throw APIError.invalidResponse }
            guard let url = URL(string: accessTokenService.serviceEndpoint) else {  throw APIError.invalidResponse }

            return Promise.value
//            guard let serviceInfo = validationServiceInfo else { return }
//
//            let pubKey = (X509.derPubKey(for: privateKey) ?? Data()).base64EncodedString()
//
//            GatewayConnection.getAccessTokenFor(url: url,servicePath: service.id, publicKey: pubKey) { response in
//                DispatchQueue.main.async { [weak self] in
//                    self?.performSegue(withIdentifier: Constants.showCertificatesList, sender: (serviceInfo, response))
//                }
//            }
        }
        .done { identityDocument in
            
        }

    }
    
    public func decodeInitialisationQRCode(payload: String) -> ValidationServiceInitialisation? {
        guard let data = payload.data(using: .utf8),
              let ticket = try? JSONDecoder().decode(ValidationServiceInitialisation.self, from: data) else {
                  return nil
              }
        self.ticket = ticket
        return ticket
    }
}
