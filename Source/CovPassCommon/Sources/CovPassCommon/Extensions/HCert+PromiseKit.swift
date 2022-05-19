//
//  HCert+PromiseKit.swift
//  
//
//  Created by Thomas Kuleßa on 28.02.22.
//

import Foundation
import PromiseKit

extension HCert {
    static func verifyPromise(message: CoseSign1Message, trustList: TrustList) -> Promise<TrustCertificate> {
        do {
            let trustCertificate = try verify(message: message, trustList: trustList)
            return .value(trustCertificate)
        } catch  {
            return .init(error: error)
        }
    }

    static func checkExtendedKeyUsagePromise(certificate: CBORWebToken, trustCertificate: TrustCertificate) -> Promise<Void> {
        do {
            try checkExtendedKeyUsage(certificate: certificate, trustCertificate: trustCertificate)
            return .value
        } catch {
            return .init(error: error)
        }
    }
}
