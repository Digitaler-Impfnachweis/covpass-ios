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
    mutating func decodeInitialisationQRCode(payload: String) -> ValidationServiceInitialisation?
    func fetchValidationService() -> Promise<AccessTokenResponse>
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
    
    private func accessToken(string: String) throws -> Promise<AccessTokenResponse> {
        Promise { seal in
            let decoded = try decode(jwt: try string) as AccessTokenResponse
            seal.fulfill(decoded)
        }
    }
    
    public func fetchValidationService() -> Promise<AccessTokenResponse> {
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
        .then { identityDocument -> Promise<String> in
            let serverListInfo = self.identityDocumentDecorator
            guard var services = serverListInfo?.service else { throw APIError.invalidResponse }
            guard let validationService = services.filter({ $0.type == "ValidationService" }).first else { throw APIError.invalidResponse }
            services[0].isSelected = true
            guard let accessTokenService = services.first(where: { $0.type == "AccessTokenService" }) else {  throw APIError.invalidResponse }
            guard let url = URL(string: accessTokenService.serviceEndpoint) else {  throw APIError.invalidResponse }
            guard let privateKey = Enclave.loadOrGenerateKey(with: "validationKey") else { throw APIError.invalidResponse  }
            let pubKey = (X509.derPubKey(for: privateKey) ?? Data()).base64EncodedString()
            return self.service.getAccessTokenFor(url: url, servicePath: validationService.id, publicKey: pubKey)
//
//                DispatchQueue.main.async { [weak self] in
//                    self?.performSegue(withIdentifier: Constants.showCertificatesList, sender: (serviceInfo, response))
//                }
//            }
        }
        .then { stringResponse -> Promise<AccessTokenResponse> in
            return try self.accessToken(string: stringResponse)
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


/*-
 * ---license-start
 * eu-digital-green-certificates / dgca-app-core-ios
 * ---
 * Copyright (C) 2021 T-Systems International GmbH and all other contributors
 * ---
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ---license-end
 */
//
//  X509.swift
//
//
//  Created by Yannick Spreen on 4/17/21.
//

import Foundation
import ASN1Decoder

public class X509 {
  
  static let OID_TEST = "1.3.6.1.4.1.1847.2021.1.1"
  static let OID_ALT_TEST = "1.3.6.1.4.1.0.1847.2021.1.1"
  static let OID_VACCINATION = "1.3.6.1.4.1.1847.2021.1.2"
  static let OID_ALT_VACCINATION = "1.3.6.1.4.1.0.1847.2021.1.2"
  static let OID_RECOVERY = "1.3.6.1.4.1.1847.2021.1.3"
  static let OID_ALT_RECOVERY = "1.3.6.1.4.1.0.1847.2021.1.3"
  
  public static func pubKey(from b64EncodedCert: String) -> SecKey? {
    guard
      let encodedCertData = Data(base64Encoded: b64EncodedCert),
      let cert = SecCertificateCreateWithData(nil, encodedCertData as CFData),
      let publicKey = SecCertificateCopyKey(cert)
    else {
      return nil
    }
    return publicKey
  }
  
  public static func derPubKey(for secKey: SecKey) -> Data? {
    guard
      let pubKey = SecKeyCopyPublicKey(secKey)
    else {
      return nil
    }
    return derKey(for: pubKey)
  }
  
  public static func derKey(for secKey: SecKey) -> Data? {
    var error: Unmanaged<CFError>?
    guard
      let publicKeyData = SecKeyCopyExternalRepresentation(secKey, &error)
    else {
      return nil
    }
    return exportECPublicKeyToDER(publicKeyData as Data, keyType: kSecAttrKeyTypeEC as String, keySize: 384)
  }
  
  static func exportECPublicKeyToDER(_ rawPublicKeyBytes: Data, keyType: String, keySize: Int) -> Data {
    let curveOIDHeader: [UInt8] = [
      0x30,
      0x59,
      0x30,
      0x13,
      0x06,
      0x07,
      0x2A,
      0x86,
      0x48,
      0xCE,
      0x3D,
      0x02,
      0x01,
      0x06,
      0x08,
      0x2A,
      0x86,
      0x48,
      0xCE,
      0x3D,
      0x03,
      0x01,
      0x07,
      0x03,
      0x42,
      0x00
    ]
    var data = Data(bytes: curveOIDHeader, count: curveOIDHeader.count)
    data.append(rawPublicKeyBytes)
    return data
  }
  
  static func checkisSuitable(cert: String, certType: CertType) -> Bool{
    return isSuitable(cert: Data(base64Encoded:  cert)!, for: certType)
  }
  
  static func isCertificateValid(cert: String) -> Bool {
    guard let data = Data(base64Encoded:  cert) else { return true }
    guard let certificate = try? X509Certificate(data: data) else {
      return false
    }
    if (certificate.notAfter ?? Date()) > Date() {
      return true
    } else {
      return false
    }
  }
  
  static func isSuitable(cert: Data,for certType: CertType) -> Bool {
    guard let certificate = try? X509Certificate(data: cert) else {
      return false
    }
    if isType(in: certificate) {
      switch certType {
      case .test:
        return nil != certificate.extensionObject(oid: OID_TEST) || nil != certificate.extensionObject(oid: OID_ALT_TEST)
      case .vaccination:
        return nil != certificate.extensionObject(oid: OID_VACCINATION) || nil != certificate.extensionObject(oid: OID_ALT_VACCINATION)
      case .recovery:
        return nil != certificate.extensionObject(oid: OID_RECOVERY) || nil != certificate.extensionObject(oid: OID_ALT_RECOVERY)
      }
    }
    return true
  }
  
  static func isType(in certificate: X509Certificate) -> Bool {
    return nil != certificate.extensionObject(oid: OID_TEST)
      || nil != certificate.extensionObject(oid: OID_VACCINATION)
      || nil != certificate.extensionObject(oid: OID_RECOVERY)
      || nil != certificate.extensionObject(oid: OID_ALT_TEST)
      || nil != certificate.extensionObject(oid: OID_ALT_VACCINATION)
      || nil != certificate.extensionObject(oid: OID_ALT_RECOVERY)
  }
}


//
/*-
 * ---license-start
 * eu-digital-green-certificates / dgca-app-core-ios
 * ---
 * Copyright (C) 2021 T-Systems International GmbH and all other contributors
 * ---
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ---license-end
 */
//
//  Enclave.swift
//
//
//  Created by Yannick Spreen on 4/25/21.
//

import Foundation

public class Enclave {
  static let encryptAlg = SecKeyAlgorithm.eciesEncryptionCofactorVariableIVX963SHA256AESGCM
  static let signAlg = SecKeyAlgorithm.ecdsaSignatureMessageX962SHA512

  static func tag(for name: String) -> Data {
    "\(Bundle.main.bundleIdentifier ?? "app").\(name)".data(using: .utf8)!
  }

  static func generateKey(with name: String? = nil) -> (SecKey?, String?) {
    let name = name ?? UUID().uuidString
    let tag = Enclave.tag(for: name)
    var error: Unmanaged<CFError>?
    guard
      let access =
        SecAccessControlCreateWithFlags(
          kCFAllocatorDefault,
          kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
          [.privateKeyUsage],
          &error
        )
    else {
      return (nil, error?.takeRetainedValue().localizedDescription)
    }
    var attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeEC,
      kSecAttrKeySizeInBits as String: 256,
      kSecPrivateKeyAttrs as String: [
        kSecAttrIsPermanent as String: true,
        kSecAttrApplicationTag as String: tag,
        kSecAttrAccessControl as String: access
      ]
    ]
    #if !targetEnvironment(simulator)
    attributes[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
    #endif
    guard
      let privateKey = SecKeyCreateRandomKey(
        attributes as CFDictionary,
        &error
      )
    else {
      return (nil, error?.takeRetainedValue().localizedDescription)
    }
    return (privateKey, nil)
  }

  static func loadKey(with name: String) -> SecKey? {
    let tag = Enclave.tag(for: name)
    let query: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrKeyType as String: kSecAttrKeyTypeEC,
      kSecAttrApplicationTag as String: tag,
      kSecReturnRef as String: true
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard
      status == errSecSuccess,
      case let result as SecKey? = item
    else {
      return nil
    }
    return result
  }

  public static func loadOrGenerateKey(with name: String) -> SecKey? {
    if let key = loadKey(with: name) {
      return key
    }
    return generateKey(with: name).0
  }

  static func encrypt(data: Data, with key: SecKey) -> (Data?, String?) {
    guard let publicKey = SecKeyCopyPublicKey(key) else {
        return (nil, "err.pub-key-irretrievable")
    }
    guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, encryptAlg) else {
      return (nil, "err.alg-not-supported")
    }
    var error: Unmanaged<CFError>?
    let cipherData = SecKeyCreateEncryptedData(
      publicKey,
      encryptAlg,
      data as CFData,
      &error
    ) as Data?
    let err = error?.takeRetainedValue().localizedDescription
    return (cipherData, err)
  }

  static func decrypt(data: Data, with key: SecKey, completion: @escaping (Data?, String?) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      let (result, error) = syncDecrypt(data: data, with: key)
      completion(result, error)
    }
  }

  static func syncDecrypt(data: Data, with key: SecKey) -> (Data?, String?) {
    guard SecKeyIsAlgorithmSupported(key, .decrypt, encryptAlg) else {
      return (nil, "err.alg-not-supported")
    }
    var error: Unmanaged<CFError>?
    let clearData = SecKeyCreateDecryptedData(
      key,
      encryptAlg,
      data as CFData,
      &error
    ) as Data?
    let err = error?.takeRetainedValue().localizedDescription
    return (clearData, err)
  }

  static func verify(data: Data, signature: Data, with key: SecKey) -> (Bool, String?) {
    guard let publicKey = SecKeyCopyPublicKey(key) else {
      return (false, "err.pub-key-irretrievable")
    }
    guard SecKeyIsAlgorithmSupported(publicKey, .verify, signAlg) else {
      return (false, "err.alg-not-supported")
    }
    var error: Unmanaged<CFError>?
    let isValid = SecKeyVerifySignature(
      publicKey,
      signAlg,
      data as CFData,
      signature as CFData,
      &error
    )
    let err = error?.takeRetainedValue().localizedDescription
    return (isValid, err)
  }

  public static func sign(
    data: Data,
    with key: SecKey,
    using algorithm: SecKeyAlgorithm? = nil,
    completion: @escaping (Data?, String?) -> Void
  ) {
    DispatchQueue.global(qos: .userInitiated).async {
      let (result, error) = syncSign(data: data, with: key, using: algorithm)
      completion(result, error)
    }
  }

  static func syncSign(
    data: Data,
    with key: SecKey,
    using algorithm: SecKeyAlgorithm? = nil
  ) -> (Data?, String?) {
    let algorithm = algorithm ?? signAlg
    guard SecKeyIsAlgorithmSupported(key, .sign, algorithm) else {
      return (nil, "err.alg-not-supported")
    }
    var error: Unmanaged<CFError>?
    let signature = SecKeyCreateSignature(
      key,
      algorithm,
      data as CFData,
      &error
    ) as Data?
    let err = error?.takeRetainedValue().localizedDescription
    return (signature, err)
  }
}


