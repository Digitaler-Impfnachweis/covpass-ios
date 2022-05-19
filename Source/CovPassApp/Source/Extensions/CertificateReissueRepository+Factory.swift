//
//  CertificateReissueRepository+Factory.swift
//  
//
//  Created by Thomas Kuleßa on 18.02.22.
//

import CovPassCommon
import Foundation

public extension CertificateReissueRepository {
    convenience init?() {
        let keychain = KeychainPersistence()
        let jsonDecoder = JSONDecoder()
        let jsonEncoder = JSONEncoder()
        let baseURL = XCConfiguration.certificateReissueURL
        guard let trustListURL = Bundle.commonBundle.url(forResource: XCConfiguration.staticTrustListResource, withExtension: nil) else {
            return nil
        }
        let dataTaskProducer = DataTaskProducer(
            urlSession:URLSession.certificateReissue()
        )
        let httpClient = HTTPClient(
            dataTaskProducer: dataTaskProducer
        )
        guard let trustListData = keychain.trustList ?? (try? Data(contentsOf: trustListURL)),
              let trustList = try? jsonDecoder.decode(TrustList.self, from: trustListData) else {
            return nil
        }

        self.init(
            baseURL: baseURL,
            jsonDecoder: jsonDecoder,
            jsonEncoder: jsonEncoder,
            trustList: trustList,
            httpClient: httpClient
        )
    }
}

extension XCConfiguration {
    static var certificateReissueURL: URL {
        Self.value(URL.self, forKey: "CERTIFICATE_REISSUE_URL")
    }

    static var staticTrustListResource: String {
        Self.value(String.self, forKey: "TRUST_LIST_STATIC_DATA")
    }
}

private extension Persistence {
    var trustList: Data? {
        get {
            let value = try? fetch(KeychainPersistence.Keys.trustList.rawValue) as? Data
            return value
        }
        set {
            try? store(KeychainPersistence.Keys.trustList.rawValue, value: newValue as Any)
        }
    }
}
