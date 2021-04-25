//
//  VaccinationCertificateService.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import Keychain
import PromiseKit

public class VaccinationCertificateService {
    public init() {}

    public func save(_ certificate: VaccinationCertificateList) -> Promise<Void> {
        return Promise { seal in
            let data = try JSONEncoder().encode(certificate)
            try Keychain.storePassword(data, for: KeychainConfiguration.vaccinationCertificateKey)
            seal.fulfill_()
        }
    }

    public func fetch() -> Promise<VaccinationCertificateList> {
        return Promise { seal in
            do {
                guard let data = try Keychain.fetchPassword(for: KeychainConfiguration.vaccinationCertificateKey) else {
                    // TODO replace ApplicationError
                    throw ApplicationError.general("Could not find certificate in Keychain")
                }
                let certificate = try JSONDecoder().decode(VaccinationCertificateList.self, from: data)
                seal.fulfill(certificate)
            } catch {
                // FIXME KeychainError is internal. It needs to be public so we can use it
    //            if error == KeychainError.fetch {
    //                return nil
    //            }
    //                throw error
                seal.fulfill(VaccinationCertificateList(certificates: []))
            }
        }
    }
}
