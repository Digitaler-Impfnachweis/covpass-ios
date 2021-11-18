//
//  File.swift
//  
//
//  Created by Andreas Kostuch on 12.11.21.
//

import Foundation
import PromiseKit
import ASN1Decoder
import Foundation
import Security
import SwiftCBOR
import JWTDecode

public protocol VAASRepositoryProtocol {
    func fetchValidationService() -> Promise<AccessTokenResponse>
    func validateTicketing (choosenCert cert: ExtendedCBORWebToken) throws -> Promise<Void>
}

public class VAASRepository: VAASRepositoryProtocol {
    
    private let service: APIServiceProtocol
    private var ticket: ValidationServiceInitialisation
    var identityDocumentDecorator: IdentityDocument?
    var accessTokenInfo: AccessTokenResponse?

    public init(service: APIServiceProtocol, ticket: ValidationServiceInitialisation) {
        self.service = service
        self.ticket = ticket
    }
    
    private func identityDocument(identityString: String) throws -> Promise<IdentityDocument> {
        Promise { seal in
            seal.fulfill(try JSONDecoder().decode(IdentityDocument.self, from: identityString.data(using: .utf8)!))
        }
    }
    
    private func accessToken(string: String) throws -> Promise<AccessTokenResponse> {
        Promise { seal in
            let decodedJWT = try decode(jwt: string)
            let jsondata = try JSONSerialization.data(withJSONObject: decodedJWT.body)
            seal.fulfill(try JSONDecoder().decode(AccessTokenResponse.self, from: jsondata))
        }
    }
    
    public func fetchValidationService() -> Promise<AccessTokenResponse> {
        firstly {
            service.vaasListOfServices(url: ticket.serviceIdentity)
        }
        .then { [weak self] stringResponse in
            try (self?.identityDocument(identityString: stringResponse) ?? .init(error: APIError.requestCancelled))
        }
        .then { [weak self] identityDocument -> Promise<String> in
            guard let service = identityDocument.service?.first,
                  let serviceURL = URL(string: service.serviceEndpoint)
            else { throw APIError.invalidResponse }
            self?.identityDocumentDecorator = identityDocument
            return self?.service.vaasListOfServices(url: serviceURL) ?? .init(error: APIError.requestCancelled)
        }
        .then { [weak self] stringResponse -> Promise<IdentityDocument> in
            return try self?.identityDocument(identityString: stringResponse) ?? .init(error: APIError.requestCancelled)
        }
        .then { [weak self] identityDocument -> Promise<String> in
            guard var services = self?.identityDocumentDecorator?.service else { throw APIError.invalidResponse }
            guard let validationService = services.filter({ $0.type == "ValidationService" }).first else { throw APIError.invalidResponse }
            services[0].isSelected = true
            guard let accessTokenService = services.first(where: { $0.type == "AccessTokenService" }) else {  throw APIError.invalidResponse }
            guard let url = URL(string: accessTokenService.serviceEndpoint) else {  throw APIError.invalidResponse }
            guard let privateKey = Enclave.loadOrGenerateKey(with: "validationKey") else { throw APIError.invalidResponse  }
            guard let ticketToken = self?.ticket.token.string else { throw APIError.invalidResponse  }
            let pubKey = (X509.derPubKey(for: privateKey) ?? Data()).base64EncodedString()
            return self?.service.getAccessTokenFor(url: url,
                                                   servicePath: validationService.id,
                                                   publicKey: pubKey,
                                                   ticketToken: ticketToken) ?? .init(error: APIError.requestCancelled)
        }
        .then { [weak self] stringResponse -> Promise<AccessTokenResponse> in
            let accessTokenResponse = try self?.accessToken(string: stringResponse) ?? .init(error: APIError.requestCancelled)
            self?.accessTokenInfo = accessTokenResponse.value
            return accessTokenResponse
        }
    }
    
    public func validateTicketing (choosenCert cert: ExtendedCBORWebToken) throws -> Promise<Void> {
        guard let urlPath = accessTokenInfo?.aud!,
              let url = URL(string: urlPath),
              let iv = UserDefaults.standard.object(forKey: "xnonce"),
              let verificationMethod = identityDocumentDecorator?.verificationMethod?.first(where: { $0.publicKeyJwk?.use == "enc" }) else  { throw APIError.invalidResponse }
              let certificate = cert
        
        guard let dccData = encodeDCC(dgcString: certificate.vaccinationQRCodeData, iv: iv as! String),
              let privateKey = Enclave.loadOrGenerateKey(with: "validationKey") else { throw APIError.invalidResponse }
        
        var sig = Data()
        
        Enclave.sign(data: dccData.0, with: privateKey, using: SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256, completion: { (signature,error) in
            if let sign = signature {
                sig = sign
                let parameters = ["kid" : verificationMethod.publicKeyJwk!.kid, "dcc" : dccData.0.base64EncodedString(),
                                  "sig": sig.base64EncodedString(),"encKey" : dccData.1.base64EncodedString(),
                                  "sigAlg" : "SHA256withECDSA", "encScheme" : "RSAOAEPWithSHA256AESGCM"]
                
//                GatewayConnection.validateTicketing(url: url, parameters: parameters) { [weak self] responseModel in
//                    DispatchQueue.main.async {
//                        self?.stopActivity()
//                        self?.performSegue(withIdentifier: Constants.showValidationResult, sender: responseModel)
//                    }
//                }
            }
        })
        
        return Promise.value
    }
    
    private func encodeDCC(dgcString : String, iv: String) -> (Data,Data)? {
        guard (iv.count > 16 || iv.count < 16 || iv.count % 8 > 0) else { return nil }
        guard let verificationMethod = identityDocumentDecorator!.verificationMethod!.first(where: { $0.publicKeyJwk?.use == "enc" }) else { return nil }
        
        let ivData : [UInt8] = Array(base64: iv)
        let dgcData : [UInt8] = Array(dgcString.utf8)
        let _ : [UInt8] = Array(base64: verificationMethod.publicKeyJwk!.x5c.first!)
        var encryptedDgcData : [UInt8] = Array()
        
        // AES GCM
        let password: [UInt8] = Array("s33krit".utf8)
        let salt: [UInt8] = Array("nacllcan".utf8)
        
        /* Generate a key from a `password`. Optional if you already have a key */
        let key = try! PKCS5.PBKDF2(password: password, salt: salt, iterations: 4096, keyLength: 32, /* AES-256 */
                                    variant: .sha2(.sha256)
        ).calculate()
        
        let publicSecKey = VAASRepository.pubKey(from: verificationMethod.publicKeyJwk!.x5c.first!)
        
        do {
            let gcm = GCM(iv: ivData, mode: .combined)
            let aes = try AES(key: key, blockMode: gcm, padding: .noPadding)
            encryptedDgcData = try aes.encrypt(dgcData)
            //        let tag = gcm.authenticationTag
            
        } catch {
            print(error.localizedDescription)
        }
        let encryptedKeyData = VAASRepository.encrypt(data: Data(key), with: publicSecKey!)
        return (Data(encryptedDgcData), encryptedKeyData.0!)
    }
    
    private static func encrypt(data: Data, with key: SecKey) -> (Data?, String?) {
        guard let publicKey = SecKeyCopyPublicKey(key) else {
            return (nil, ("err.pub-key-irretrievable"))
        }
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, SecKeyAlgorithm.rsaEncryptionOAEPSHA256) else {
            return (nil, ("err.alg-not-supported"))
        }
        var error: Unmanaged<CFError>?
        let cipherData = SecKeyCreateEncryptedData(publicKey, SecKeyAlgorithm.rsaEncryptionOAEPSHA256,
                                                   data as CFData, &error) as Data?
        let err = error?.takeRetainedValue().localizedDescription
        return (cipherData, err)
    }
    
    private func keyFromData(_ data: Data) throws -> SecKey {
        let options: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                      kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                                      kSecAttrKeySizeInBits as String : 4096]
        
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(data as CFData,
                                             options as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        return key
    }
    
    private static func pubKey(from b64EncodedCert: String) -> SecKey? {
        guard
            let encodedCertData = Data(base64Encoded: b64EncodedCert),
            let cert = SecCertificateCreateWithData(nil, encodedCertData as CFData),
            let publicKey = SecCertificateCopyKey(cert)
        else { return nil }
        return publicKey
    }
}
