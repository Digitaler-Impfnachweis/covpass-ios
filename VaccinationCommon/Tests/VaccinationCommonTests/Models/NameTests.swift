//
//  VaccinationTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationCommon

import Foundation
import XCTest

class NameTests: XCTestCase {
    func testDecoding() {
        let jsonData = Data.json("Name")
        let sut = try! JSONDecoder().decode(Name.self, from: jsonData)

        XCTAssertEqual(sut.gn, "Erika Dörte")
        XCTAssertEqual(sut.fn, "Schmitt Mustermann")
        XCTAssertEqual(sut.gnt, "ERIKA<DOERTE")
        XCTAssertEqual(sut.fnt, "SCHMITT<MUSTERMANN")
    }
}
