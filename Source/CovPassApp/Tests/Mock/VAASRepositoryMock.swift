//
//  VAASRepositoryMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import PromiseKit
import Foundation

struct VAASRepositoryMock: VAASRepositoryProtocol {
    var ticket = ValidationServiceInitialisation.mock

    var selectedValidationService: ValidationService?

    func fetchValidationService() -> Promise<AccessTokenResponse> {
        .value(AccessTokenResponse(vc: ValidationCertificate(fnt: "Schneider", gnt: "Andrea", dob: "1990-07-12", type: ["v", "r", "t"])))
    }

    func validateTicketing(choosenCert cert: ExtendedCBORWebToken) throws -> Promise<Void> {
        .value(())
    }

}
