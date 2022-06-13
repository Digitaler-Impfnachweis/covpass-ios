//
//  CoseSign1MessageConverter+Factory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon

extension CoseSign1MessageConverter {
    init?() {
        let keychain = KeychainPersistence()
        let jsonDecoder = JSONDecoder()
        guard let trustListURL = Bundle.commonBundle.url(forResource: XCConfiguration.staticTrustListResource, withExtension: nil),
              let trustListData = keychain.trustList ?? (try? Data(contentsOf: trustListURL)),
              let trustList = try? jsonDecoder.decode(TrustList.self, from: trustListData) else {
            return nil
        }

        self.init(jsonDecoder: jsonDecoder, trustList: trustList)
    }
}
