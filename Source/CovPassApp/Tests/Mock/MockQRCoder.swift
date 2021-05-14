//
//  MockQRCoder.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import VaccinationCommon
import CovPassUI

class MockQRCoder: QRCoderProtocol {
    func parse(_: String) -> Promise<CBORWebToken> {
        return Promise { seal in
            let jsonData = Data.json()
            let cert = try JSONDecoder().decode(CBORWebToken.self, from: jsonData)
            seal.fulfill(cert)
        }
    }
}

extension Data {
    static func json() -> Data {
        let json = """
            {
                "name": "Mustermann Erika",
                "birthDate": "19640812",
                "identifier": "C01X00T47",
                "sex": "female",
                "vaccination": [{
                    "targetDisease": "U07.1!",
                    "vaccineCode": "1119349007",
                    "product": "COMIRNATY",
                    "manufacturer": "BioNTech Manufacturing GmbH",
                    "series": "2/2",
                    "lotNumber": "T654X4",
                    "occurrence": "20210202",
                    "location": "84503",
                    "performer": "999999900",
                    "country": "DE",
                    "nextDate": "20210402"
                }],
                "issuer": "Landratsamt Altötting",
                "id": "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S",
                "validFrom": "20200202",
                "validUntil": "20230202",
                "version": "1.0.0",
                "secret": "ZFKIYIBK39A3#S"
            }
        """
        return json.data(using: .utf8)!
    }
}
