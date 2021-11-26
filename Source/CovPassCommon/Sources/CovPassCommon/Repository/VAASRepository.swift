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
import CryptoSwift

public enum VAASStep {
    case downloadIdentityDecorator
    case downloadIdentityService
    case downloadAccessToken
}

public enum VAASErrors: Error, ErrorCode {
    case identityDocumentDecoratorNotFound
    case identityValidationServiceNotFound
    case validationServicesNotFound
    case accessTokenServiceNotFound
    case fetchingPrivatKeyFailed
    case qrCodeTokenNotFound
    case fetchingPublicKeyFromPrivatKeyFailed
    case unexpectedError
    case notInTrustList
    case encodingDCCFailed
    case signingDCCFailed
    case accessTokenJWTNotFound
    case accessTokenJWKNotFound

    public var errorCode: Int {
        switch self {
        case .identityDocumentDecoratorNotFound:
            return 431
        case .identityValidationServiceNotFound:
            return 432
        case .validationServicesNotFound:
            return 433
        case .accessTokenServiceNotFound:
            return 434
        case .fetchingPrivatKeyFailed:
            return 435
        case .qrCodeTokenNotFound:
            return 436
        case .fetchingPublicKeyFromPrivatKeyFailed:
            return 437
        case .unexpectedError:
            return 438
        case .notInTrustList:
            return 439
        case .encodingDCCFailed:
            return 440
        case .signingDCCFailed:
            return 441
        case .accessTokenJWTNotFound:
            return 442
        case .accessTokenJWKNotFound:
            return 444
        }
    }
}

public protocol VAASRepositoryProtocol {
    var ticket: ValidationServiceInitialisation {get}
    var selectedValidationService: ValidationService? {get}
    var step: VAASStep { get set }
    func fetchValidationService() -> Promise<AccessTokenResponse>
    func validateTicketing (choosenCert cert: ExtendedCBORWebToken) throws -> Promise<VAASValidaitonResultToken>
}

public class VAASRepository: VAASRepositoryProtocol {
    
    public var step: VAASStep
    private let service: APIServiceProtocol
    public private(set) var ticket: ValidationServiceInitialisation
    var identityDocumentDecorator: IdentityDocument?
    var identityDocumentValidationService: IdentityDocument?
    var accessTokenInfo: AccessTokenResponse?
    public private(set) var selectedValidationService: ValidationService?
    var accessTokenJWT: String?

    public init(service: APIServiceProtocol, ticket: ValidationServiceInitialisation) {
        self.service = service
        self.ticket = ticket
        self.step = .downloadIdentityDecorator
    }
    
    public func fetchValidationService() -> Promise<AccessTokenResponse> {
        self.step = .downloadIdentityDecorator
        return firstly {
            return service.vaasListOfServices(url: ticket.serviceIdentity)
        }
        .then { [weak self] stringResponse in
            try self?.identityDocument(identityString: stringResponse) ?? .init(error: APIError.invalidResponse)
        }
        .then { [weak self] identityDocument -> Promise<String> in
            
            guard let self = self else {
                throw VAASErrors.unexpectedError
            }
            
            self.step = .downloadIdentityService
            
            guard let services = identityDocument.service else {
                throw VAASErrors.validationServicesNotFound
            }
            
            let validationServices = services.filter({ $0.type == "ValidationService" })
            
            guard !validationServices.isEmpty else {
                throw VAASErrors.validationServicesNotFound
            }
            
            self.identityDocumentDecorator = identityDocument
            
            return self.callValidationServices(validationServices)
        }
        .then { [weak self] stringResponse -> Promise<IdentityDocument> in
            return try self?.prepareIdentityDocumentValidationService(stringResponse) ?? .init(error: VAASErrors.unexpectedError)
        }
        .then { [weak self] identityDocument -> Promise<String> in
            
            guard let self = self else {
                throw VAASErrors.unexpectedError
            }
            
            self.step = .downloadAccessToken
            
            guard let identityDocumentDecorator = self.identityDocumentDecorator else {
                throw VAASErrors.identityDocumentDecoratorNotFound
            }
            
            guard let services = identityDocumentDecorator.service else {
                throw VAASErrors.validationServicesNotFound
            }
            
            guard let servicePath = self.selectedValidationService?.id else {
                throw VAASErrors.validationServicesNotFound
            }
            
            guard let accessTokenService = services.first(where: { $0.type == "AccessTokenService" }) else {
                throw VAASErrors.accessTokenServiceNotFound
            }
            
            guard let url = URL(string: accessTokenService.serviceEndpoint) else {
                throw APIError.invalidUrl
            }
            
            guard let privateKey = Enclave.loadOrGenerateKey(with: "validationKey") else {
                throw VAASErrors.fetchingPrivatKeyFailed
            }
            
            guard let pubKey = X509.derPubKey(for: privateKey)?.base64EncodedString() else {
                throw VAASErrors.fetchingPublicKeyFromPrivatKeyFailed
            }

            return self.service.getAccessTokenFor(url: url, servicePath: servicePath, publicKey: pubKey, ticketToken: self.ticket.token.string)
        }
        .then { [weak self] stringResponse -> Promise<AccessTokenResponse> in
            
            guard let self = self else {
                throw VAASErrors.unexpectedError
            }
            
            let accessTokenResponse = try self.accessToken(string: stringResponse)
            self.accessTokenJWT = stringResponse
            self.accessTokenInfo = accessTokenResponse.value
            return accessTokenResponse
        }
    }
    
    public func validateTicketing(choosenCert certificate: ExtendedCBORWebToken) -> Promise<VAASValidaitonResultToken> {
        firstly {
            try validateTicket(certificate: certificate)
        }
        .then { [weak self] stringResponse -> Promise<VAASValidaitonResultToken> in
            guard let decodedJWT = try? decode(jwt: stringResponse),
            let jsondata = try? JSONSerialization.data(withJSONObject: decodedJWT.body),
                  var vaasValidationResultToken = try? JSONDecoder().decode(VAASValidaitonResultToken.self, from: jsondata) else {
                      return .init(error: APIError.requestCancelled)
                  }
            vaasValidationResultToken.provider = self?.ticket.subject
            vaasValidationResultToken.verifyingService = self?.selectedValidationService?.name
            return .value(vaasValidationResultToken)
        }
    }
    
    func validateTicket(certificate: ExtendedCBORWebToken) throws -> Promise<String> {
        guard let identityDocumentValidationService = identityDocumentValidationService else {
            throw VAASErrors.identityValidationServiceNotFound
        }

        guard let urlPath = self.accessTokenInfo?.aud, let url = URL(string: urlPath) else {
            throw APIError.invalidUrl
        }
        
        guard let iv = UserDefaults.standard.object(forKey: "xnonce") as? String else {
            throw VAASErrors.unexpectedError
        }
        
        guard let verificationMethod = identityDocumentValidationService.verificationMethod?.first(where: { $0.publicKeyJwk?.use == "enc" }) else {
            throw VAASErrors.unexpectedError
        }
        
        guard let dccData = encodeDCC(dgcString: certificate.vaccinationQRCodeData, iv: iv) else {
            throw VAASErrors.encodingDCCFailed
        }
        
        guard let privateKey = Enclave.loadOrGenerateKey(with: "validationKey") else {
            throw VAASErrors.fetchingPrivatKeyFailed
        }
        
        return firstly {
            return Enclave.sign(data: dccData.0, with: privateKey, using: SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256)
        }
        .then { signature, error -> Promise<String> in
            
            guard error == nil, let sign = signature else {
                throw VAASErrors.signingDCCFailed
            }
            
            guard let accessTokenJWT = self.accessTokenJWT else {
                throw VAASErrors.accessTokenJWTNotFound
            }
            
            guard let kid = verificationMethod.publicKeyJwk?.kid else {
                throw VAASErrors.accessTokenJWKNotFound
            }
            
            let parameters = ["kid" : kid,
                              "dcc" : dccData.0.base64EncodedString(),
                              "sig": sign.base64EncodedString(),
                              "encKey" : dccData.1.base64EncodedString(),
                              "sigAlg" : "SHA256withECDSA",
                              "encScheme" : "RSAOAEPWithSHA256AESGCM"]
            return self.service.validateTicketing(url: url, parameters: parameters, accessToken: accessTokenJWT)
        }
    }
    
    public func cancellation() {
        guard let urlString = self.identityDocumentDecorator?.service?.first(where: { $0.type == "CancellationService" })?.serviceEndpoint,
                let url = URL(string: urlString) else {
            return
        }
        _ = service.cancellTicket(url: url, ticketToken: self.ticket.token.string)
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
    
    private func prepareIdentityDocumentValidationService(_ stringResponse: String) throws -> Promise<IdentityDocument> {
        let identityDocumentValidationService = try self.identityDocument(identityString: stringResponse)
        self.identityDocumentValidationService = identityDocumentValidationService.value
        return identityDocumentValidationService
    }
    
    private func callValidationServices(_ validationServices: [ValidationService]) -> Promise<String> {
        Promise { seal in
            func next(_ services: [ValidationService]) {
                var services = services
                guard services.isEmpty == false else {
                    seal.reject(VAASErrors.validationServicesNotFound)
                    return
                }
                callValidationService(validationService: services.removeFirst()) { response in
                    if let response = response {
                        seal.fulfill(response)
                    } else {
                        next(services)
                    }
                }
            }
            next(validationServices.reversed())
        }
    }
    
    private func callValidationService(validationService: ValidationService, completion: ((String?) -> Void)?) {
        guard let serviceURL = URL(string: validationService.serviceEndpoint) else {
            completion?(nil)
            return
        }
        service.vaasListOfServices(url: serviceURL).done {
            self.selectedValidationService = validationService
            completion?($0)
        }
        .catch { error in
            completion?(nil)
        }
    }
    
    private func encodeDCC(dgcString : String, iv: String) -> (Data,Data)? {
        guard (iv.count > 16 || iv.count < 16 || iv.count % 8 > 0) else { return nil }
        guard let verificationMethod = identityDocumentValidationService?.verificationMethod?.first(where: { $0.publicKeyJwk?.use == "enc" })
        else { return nil }
        
        let ivData : [UInt8] = Array(base64: iv)
        let dgcData : [UInt8] = Array(dgcString.utf8)
        let _ : [UInt8] = Array(base64: verificationMethod.publicKeyJwk!.x5c.first!)
        var encryptedDgcData : [UInt8] = Array()
        
        // AES GCM
        let password: [UInt8] = Array("s33krit".utf8)
        let salt: [UInt8] = Array("nacllcan".utf8)
        
        /* Generate a key from a `password`. Optional if you already have a key */
        let key = try! PKCS5.PBKDF2(password: password, salt: salt, iterations: 4096, keyLength: 32, /* AES-256 */
                                    variant: .sha2(.sha256)).calculate()
        
        guard let b64EncodedCert = verificationMethod.publicKeyJwk?.x5c.first else {
            // TODO: complete error
            return nil
        }
        let publicSecKey = pubKey(from: b64EncodedCert)
        do {
            let gcm = GCM(iv: ivData, mode: .combined)
            let aes = try AES(key: key, blockMode: gcm, padding: .noPadding)
            encryptedDgcData = try aes.encrypt(dgcData)
            let encryptedKeyData = encrypt(data: Data(key), with: publicSecKey!)
            return (Data(encryptedDgcData), encryptedKeyData.0!)
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private  func encrypt(data: Data, with key: SecKey) -> (Data?, String?) {
        guard let publicKey = SecKeyCopyPublicKey(key) else { return (nil, ("err.pub-key-irretrievable")) }
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, SecKeyAlgorithm.rsaEncryptionOAEPSHA256) else {
            return (nil, ("err.alg-not-supported"))
        }
        var error: Unmanaged<CFError>?
        let cipherData = SecKeyCreateEncryptedData(publicKey,
                                                   SecKeyAlgorithm.rsaEncryptionOAEPSHA256, data as CFData, &error) as Data?
        let err = error?.takeRetainedValue().localizedDescription
        return (cipherData, err)
    }
    
    private func keyFromData(_ data: Data) throws -> SecKey {
        let options: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                      kSecAttrKeyClass as String: kSecAttrKeyClassPublic, kSecAttrKeySizeInBits as String : 4096]
        
        var error: Unmanaged<CFError>?
        
        guard let key = SecKeyCreateWithData(data as CFData, options as CFDictionary, &error)
        else { throw error!.takeRetainedValue() as Error }
        return key
    }
    
    private func pubKey(from b64EncodedCert: String) -> SecKey? {
        guard let encodedCertData = Data(base64Encoded: b64EncodedCert),
              let cert = SecCertificateCreateWithData(nil, encodedCertData as CFData),
              let publicKey = SecCertificateCopyKey(cert)
        else { return nil }
        return publicKey
    }
}
