//
//  StringExtensionTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class StringExtensionTests: XCTestCase {
    func testStripPrefix() {
        XCTAssertEqual("HC1:ABC123".stripPrefix(), "ABC123")
        XCTAssertEqual("HC2:ABC123".stripPrefix(), "HC2:ABC123")
        XCTAssertEqual("ABC123HC1:".stripPrefix(), "ABC123HC1:")
        XCTAssertEqual(" HC1:ABC123".stripPrefix(), " HC1:ABC123")
    }

    func testUVCIRemoval() {
        XCTAssertEqual("URN:UVCI:01:NL:187/37512422923".stripUVCIPrefix(), "01:NL:187/37512422923")
        XCTAssertEqual("URN:UVCI:01:AT:10807843F94AEE0EE5093FBC254BD813#B".stripUVCIPrefix(),
                       "01:AT:10807843F94AEE0EE5093FBC254BD813#B")

        XCTAssertEqual("01:AT:10807843F94AEE0EE5093FBC254BD813#B".stripUVCIPrefix(),
                       "01:AT:10807843F94AEE0EE5093FBC254BD813#B")

        XCTAssertEqual(" URN:UVCI:01:AT:10807843F94AEE0EE5093FBC254BD813#B".stripUVCIPrefix(),
                       " 01:AT:10807843F94AEE0EE5093FBC254BD813#B")

        XCTAssertEqual("UVCI:01:AT:10807843F94AEE0EE5093FBC254BD813#B".stripUVCIPrefix(),
                       "UVCI:01:AT:10807843F94AEE0EE5093FBC254BD813#B")
    }

    func testXMLSanitazion() {
        XCTAssertEqual("&".sanitizedXMLString, "&amp;")
        XCTAssertEqual("&".sanitizedXMLString.sanitizedXMLString, "&amp;")
        XCTAssertEqual("&amp".sanitizedXMLString, "&amp;amp")
        XCTAssertEqual(" &amp;".sanitizedXMLString, " &amp;")

        XCTAssertEqual("<".sanitizedXMLString, "&lt;")
        XCTAssertEqual(">".sanitizedXMLString, "&gt;")
        XCTAssertEqual("\"".sanitizedXMLString, "&quot;")
        XCTAssertEqual("'".sanitizedXMLString, "&apos;")

        XCTAssertEqual("foo<".sanitizedXMLString, "foo&lt;")
        XCTAssertEqual(">bar".sanitizedXMLString, "&gt;bar")
        XCTAssertEqual("foo\"bar".sanitizedXMLString, "foo&quot;bar")
        XCTAssertEqual("🦠'💉".sanitizedXMLString, "🦠&apos;💉")
    }
}
