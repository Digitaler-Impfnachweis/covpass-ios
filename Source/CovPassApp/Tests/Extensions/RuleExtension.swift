//
//  RuleExtension.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
import SwiftyJSON

extension Rule {
    convenience init(identifier: String = "",
                     type: String = "",
                     countryCode: String = "",
                     description: [Description] = []) {
        self.init(identifier: identifier,
                  type: type,
                  version: "",
                  schemaVersion: "",
                  engine: "",
                  engineVersion: "",
                  certificateType: "",
                  description: description,
                  validFrom: "",
                  validTo: "",
                  affectedString: [],
                  logic: JSON(),
                  countryCode: countryCode,
                  region: "")
    }
}
