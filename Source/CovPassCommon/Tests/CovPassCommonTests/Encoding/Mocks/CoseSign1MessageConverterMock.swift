//
//  CoseSign1MessageConverterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import XCTest

class CoseSign1MessageConverterMock: CoseSign1MessageConverterProtocol {
    let convertExpectation = XCTestExpectation(description: "convertExpectation")
    var token: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
    var error: Error?

    func convert(message: String) -> Promise<ExtendedCBORWebToken> {
        convertExpectation.fulfill()
        if let error = error {
            return .init(error: error)
        }
        token.vaccinationQRCodeData = message
        return .value(token)
    }
}
