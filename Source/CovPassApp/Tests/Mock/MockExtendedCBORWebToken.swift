//
//  MockExtendedCBORWebToken.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest

extension ExtendedCBORWebToken {
    static func mock() throws -> Self {
        try token(from: """
            {"1":"DE","4":1782239131,"6":1619167131,"-260":{"1":{"nam":{"gn":"Erika Dörte","fn":"Schmitt Mustermann","gnt":"ERIKA<DOERTE","fnt":"SCHMITT<MUSTERMANN"},"dob":"1964-08-12","v":[{"ci":"01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S","co":"DE","dn":2,"dt":"2021-02-02","is":"Bundesministerium für Gesundheit","ma":"ORG-100030215","mp":"EU/1/20/1528","sd":2,"tg":"840539006","vp":"1119349007"}],"ver":"1.0.0"}}}
            """
        )
    }

    static func token(from cbOrWebToken: String) throws -> Self {
        let data = try XCTUnwrap(cbOrWebToken.data(using: .utf8))
        let token = try JSONDecoder().decode(CBORWebToken.self, from: data)
        let extendedToken = Self(vaccinationCertificate: token,
                                 vaccinationQRCodeData: "")
        return extendedToken
    }

    static func token1Of2() throws -> Self {
        try token(from: """
            {"1":"DE","4":1689239131,"6":1619167131,"-260":{"1":{"nam":{"gn":"Erika Dörte","fn":"Schmitt Mustermann","gnt":"ERIKA<DOERTE","fnt":"SCHMITT<MUSTERMANN"},"dob":"1964-08-12","v":[{"ci":"01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S","co":"DE","dn":1,"dt":"2021-02-02","is":"Bundesministerium für Gesundheit","ma":"ORG-100030215","mp":"EU/1/20/1528","sd":2,"tg":"840539006","vp":"1119349007"}],"ver":"1.0.0"}}}
            """
        )
    }

    static func token1Of1() throws -> Self {
        try token(from: """
            {"1":"DE","4":1782239131,"6":1619167131,"-260":{"1":{"nam":{"gn":"Erika Dörte","fn":"Schmitt Mustermann","gnt":"ERIKA<DOERTE","fnt":"SCHMITT<MUSTERMANN"},"dob":"1964-08-12","v":[{"ci":"01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S","co":"DE","dn":1,"dt":"2021-02-02","is":"Bundesministerium für Gesundheit","ma":"ORG-100030215","mp":"EU/1/20/1528","sd":1,"tg":"840539006","vp":"1119349007"}],"ver":"1.0.0"}}}
            """
        )
    }

    static func token2Of2() throws -> Self {
        try token(from: """
            {"1":"DE","4":1682239131,"6":1619167131,"-260":{"1":{"nam":{"gn":"Erika Dörte","fn":"Schmitt Mustermann","gnt":"ERIKA<DOERTE","fnt":"SCHMITT<MUSTERMANN"},"dob":"1964-08-12","v":[{"ci":"01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S","co":"DE","dn":2,"dt":"2021-03-02","is":"Bundesministerium für Gesundheit","ma":"ORG-100030215","mp":"EU/1/20/1528","sd":2,"tg":"840539006","vp":"1119349007"}],"ver":"1.0.0"}}}
            """
        )
    }

    static func token3Of3() throws -> Self {
        try token(from: """
            {"1":"DE","4":1682239131,"6":1619167131,"-260":{"1":{"nam":{"gn":"Erika Dörte","fn":"Schmitt Mustermann","gnt":"ERIKA<DOERTE","fnt":"SCHMITT<MUSTERMANN"},"dob":"1964-08-12","v":[{"ci":"01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S","co":"DE","dn":3,"dt":"2021-04-02","is":"Bundesministerium für Gesundheit","ma":"ORG-100030215","mp":"EU/1/20/1528","sd":3,"tg":"840539006","vp":"1119349007"}],"ver":"1.0.0"}}}
            """
        )
    }
}
