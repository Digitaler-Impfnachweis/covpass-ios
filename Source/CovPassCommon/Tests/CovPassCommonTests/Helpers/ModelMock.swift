//
//  ModelMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CertLogic
import SwiftyJSON
@testable import CovPassCommon

extension RuleSimple {
    static var mock: RuleSimple {
        RuleSimple(
            identifier: "",
            version: "",
            country: "DE",
            hash: ""
        )
    }

    func setIdentifier(_ identifier: String) -> RuleSimple {
        self.identifier = identifier
        return self
    }

    func setHash(_ hash: String) -> RuleSimple {
        self.hash = hash
        return self
    }

    func setCountry(_ country: String) -> RuleSimple {
        self.country = country
        return self
    }
}

extension Rule {
    static var mock: Rule {
        Rule(
            identifier: "",
            type: "",
            version: "",
            schemaVersion: "",
            engine: "",
            engineVersion: "",
            certificateType: "",
            description: [],
            validFrom: "",
            validTo: "",
            affectedString: [],
            logic: JSON(""),
            countryCode: "DE"
        )
    }

    func setIdentifier(_ identifier: String) -> Rule {
        self.identifier = identifier
        return self
    }

    func setHash(_ hash: String) -> Rule {
        self.hash = hash
        return self
    }
}
