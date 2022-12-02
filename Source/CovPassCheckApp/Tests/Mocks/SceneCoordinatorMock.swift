//
//  Mocks.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit
import SwiftyJSON
import XCTest

class SceneCoordinatorMock: SceneCoordinator {
    let dismissExpectation = XCTestExpectation(description: "dismissExpectation")
    var sceneDissmissed = false

    func asRoot(_: SceneFactory) {}

    func dismiss(animated _: Bool = true) {
        sceneDissmissed = true
        dismissExpectation.fulfill()
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
