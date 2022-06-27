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
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
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


