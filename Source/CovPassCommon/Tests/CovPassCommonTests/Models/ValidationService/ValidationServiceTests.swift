//
//  ValidationServiceTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon

import Foundation
import JWTDecode
import XCTest

class ValidationServiceTests: XCTestCase {
    func testValidationServiceInitialisationDecoding() {
        let data = json.data(using: .utf8)
        let sut = try! JSONDecoder().decode(ValidationServiceInitialisation.self, from: data!)

        XCTAssertTrue(sut.protocolName == "DCCVALIDATION")
        XCTAssertTrue(sut.protocolVersion == "1.0.0")
        XCTAssertTrue(sut.serviceIdentity == URL(string: "https://dgca-booking-demo-eu-test.cfapps.eu10.hana.ondemand.com/api/identity")!)
        XCTAssertTrue(sut.consent == "Please confirm to start the DCC Exchange flow. If you not confirm, the flow is aborted.")
        XCTAssertTrue(sut.privacyUrl == URL(string: "https://validation-decorator.example")!)
        XCTAssertTrue(sut.subject == "6a2ab591-c383-4e9a-b309-360c58dad93f")
        XCTAssertTrue(sut.serviceProvider == "Booking Demo")
        XCTAssertTrue(sut.token.issuer == "https://dgca-booking-demo-eu-test.cfapps.eu10.hana.ondemand.com/api/identity")
        XCTAssertTrue(sut.token.subject == "6a2ab591-c383-4e9a-b309-360c58dad93f")
        XCTAssertTrue(sut.token.expiresAt == Date(timeIntervalSince1970: 1_635_073_189))
    }

    func test_decode_validation_result_jwt() {
        let decodedJWT = try! decode(jwt: validationResultJWT)
        let jsondata = try! JSONSerialization.data(withJSONObject: decodedJWT.body)
        let vaasValidationResultToken = try! JSONDecoder().decode(VAASValidaitonResultToken.self, from: jsondata)
        XCTAssertTrue(vaasValidationResultToken.sub == "2027a19d-e35a-41b5-9def-471211f0ccee")
        XCTAssertTrue(vaasValidationResultToken.iss == "https://dgca-validation-service-eu-test.cfapps.eu10.hana.ondemand.com")
        XCTAssertTrue(vaasValidationResultToken.category.count == 1)
        XCTAssertTrue(vaasValidationResultToken.category.first == "Standard")
        XCTAssertTrue(vaasValidationResultToken.confirmation.jti == "a9285d62-6c06-4e85-9827-3ab2db90ae1e")
        XCTAssertTrue(vaasValidationResultToken.confirmation.sub == "2027a19d-e35a-41b5-9def-471211f0ccee")
        XCTAssertTrue(vaasValidationResultToken.confirmation.iss == "https://dgca-validation-service-eu-test.cfapps.eu10.hana.ondemand.com")
        XCTAssertTrue(vaasValidationResultToken.confirmation.iat == 1_637_746_052)
        XCTAssertTrue(vaasValidationResultToken.confirmation.exp == 1_637_832_452)
        XCTAssertTrue(vaasValidationResultToken.confirmation.result == .passed)
        XCTAssertTrue(vaasValidationResultToken.confirmation.category.first == "Standard")
        XCTAssertTrue(vaasValidationResultToken.result == .passed)
        XCTAssertTrue(vaasValidationResultToken.results.isEmpty)
    }
}

let json =
    """
    {
      "protocol": "DCCVALIDATION",
      "protocolVersion": "1.0.0",
      "serviceIdentity": "https://dgca-booking-demo-eu-test.cfapps.eu10.hana.ondemand.com/api/identity",
      "privacyUrl": "https://validation-decorator.example",
      "token": "eyJ0eXAiOiJKV1QiLCJraWQiOiJiUzhEMi9XejV0WT0iLCJhbGciOiJFUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RnY2EtYm9va2luZy1kZW1vLWV1LXRlc3QuY2ZhcHBzLmV1MTAuaGFuYS5vbmRlbWFuZC5jb20vYXBpL2lkZW50aXR5IiwiZXhwIjoxNjM1MDczMTg5LCJzdWIiOiI2YTJhYjU5MS1jMzgzLTRlOWEtYjMwOS0zNjBjNThkYWQ5M2YifQ.vo_YxeSM02knOLASRNs74qTErKWCNo9Zq8-7TVIc1HvaGkVf_r5USnUBcyDykSsmj8Ckle5lGnHAvU1krfpk3A",
      "consent": "Please confirm to start the DCC Exchange flow. If you not confirm, the flow is aborted.",
      "subject": "6a2ab591-c383-4e9a-b309-360c58dad93f",
      "serviceProvider": "Booking Demo"
    }
    """

let validationResultJWT = """
eyJ0eXAiOiJKV1QiLCJraWQiOiJSQU0yU3R3N0VrRT0iLCJhbGciOiJFUzI1NiJ9.eyJzdWIiOiIyMDI3YTE5ZC1lMzVhLTQxYjUtOWRlZi00NzEyMTFmMGNjZWUiLCJpc3MiOiJodHRwczovL2RnY2EtdmFsaWRhdGlvbi1zZXJ2aWNlLWV1LXRlc3QuY2ZhcHBzLmV1MTAuaGFuYS5vbmRlbWFuZC5jb20iLCJpYXQiOjE2Mzc3NDYwNTIsImV4cCI6MTYzNzgzMjQ1MiwiY2F0ZWdvcnkiOlsiU3RhbmRhcmQiXSwiY29uZmlybWF0aW9uIjoiZXlKcmFXUWlPaUpTUVUweVUzUjNOMFZyUlQwaUxDSmhiR2NpT2lKRlV6STFOaUo5LmV5SnFkR2tpT2lKaE9USTROV1EyTWkwMll6QTJMVFJsT0RVdE9UZ3lOeTB6WVdJeVpHSTVNR0ZsTVdVaUxDSnpkV0lpT2lJeU1ESTNZVEU1WkMxbE16VmhMVFF4WWpVdE9XUmxaaTAwTnpFeU1URm1NR05qWldVaUxDSnBjM01pT2lKb2RIUndjem92TDJSblkyRXRkbUZzYVdSaGRHbHZiaTF6WlhKMmFXTmxMV1YxTFhSbGMzUXVZMlpoY0hCekxtVjFNVEF1YUdGdVlTNXZibVJsYldGdVpDNWpiMjBpTENKcFlYUWlPakUyTXpjM05EWXdOVElzSW1WNGNDSTZNVFl6Tnpnek1qUTFNaXdpY21WemRXeDBJam9pVDBzaUxDSmpZWFJsWjI5eWVTSTZXeUpUZEdGdVpHRnlaQ0pkZlEuUHV0X2RkQlBNMmtMVFZkTWF0dVNTYjFVM0RTYnNORTJhMkh1WjVLMmZ5UVVITnM4NlBuYjh4MzFja1J3aUxmVWczTGVxcTBkNUhxNXJaN3IzTFk5WXciLCJyZXN1bHRzIjpbXSwicmVzdWx0IjoiT0sifQ.BdQr1acy81yHqBKTuVbbbO9ATYIhbT1XNit0mE3VIO-D-SLOwc-_is4_mEp8k1wD6zAMqNYk_Gl7srm5LFkz3Q
"""
