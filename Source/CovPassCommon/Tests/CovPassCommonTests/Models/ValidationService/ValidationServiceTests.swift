//
//  ValidationServiceTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon

import Foundation
import XCTest

class ValidationServiceTests: XCTestCase {

    func testValidationServiceInitialisationDecoding() {
        let data = json.data(using: .utf8)
        let sut = try! JSONDecoder().decode(ValidationServiceInitialisation.self, from: data!)

        XCTAssertTrue(sut.protocolName == "DCCVALIDATION")
        XCTAssertTrue(sut.protocolVersion == "1.0.0")
        XCTAssertTrue(sut.serviceIdentity == URL(string: "http://dccexampleprovider/dcc/identity")!)
        XCTAssertTrue(sut.consent == "I want to check your DCC to confirm your booking!:)")
        XCTAssertTrue(sut.privacyUrl == URL(string: "https://myprivacy")!)
        XCTAssertTrue(sut.subject == "Booking Nr. …")
        XCTAssertTrue(sut.serviceProvider == "Service Provider.com")
        XCTAssertTrue(sut.token.issuer == "https://dgca-booking-demo-eu-test.cfapps.eu10.hana.ondemand.com/api/identity")
        XCTAssertTrue(sut.token.subject == "6a2ab591-c383-4e9a-b309-360c58dad93f")
        XCTAssertTrue(sut.token.expiresAt == Date(timeIntervalSince1970: 1635073189))        
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
