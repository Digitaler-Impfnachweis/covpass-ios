//
//  VaccinationTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationCommon

import Foundation
import XCTest

class VaccinationTests: XCTestCase {
    func testDecoding() {
        let jsonData = Data.json("Vaccination")
        let sut = try! JSONDecoder().decode(Vaccination.self, from: jsonData)

        XCTAssertEqual(sut.tg, "840539006")
        XCTAssertEqual(sut.vp, "1119349007")
        XCTAssertEqual(sut.mp, "EU/1/20/1528")
        XCTAssertEqual(sut.ma, "ORG-100030215")
        XCTAssertEqual(sut.dn, 2)
        XCTAssertEqual(sut.sd, 2)
        XCTAssertEqual(sut.dt, DateUtils.vaccinationDateFormatter.date(from: "2021-02-02"))
        XCTAssertEqual(sut.co, "DE")
    }

    func testMapping() {
        let jsonData = Data.json("Vaccination")
        let sut = try! JSONDecoder().decode(Vaccination.self, from: jsonData)

        XCTAssertEqual(sut.map(key: sut.vp, from: Bundle.commonBundle.url(forResource: "vaccine-prophylaxis", withExtension: "json")), "SARS-CoV-2 mRNA vaccine")
        XCTAssertEqual(sut.map(key: sut.mp, from: Bundle.commonBundle.url(forResource: "vaccine-medicinal-product", withExtension: "json")), "Comirnaty")
        XCTAssertEqual(sut.map(key: sut.ma, from: Bundle.commonBundle.url(forResource: "vaccine-mah-manf", withExtension: "json")), "Biontech Manufacturing GmbH")
        XCTAssertEqual(sut.map(key: sut.co, from: Bundle.commonBundle.url(forResource: "country", withExtension: "json")), "Deutschland")
    }
}
