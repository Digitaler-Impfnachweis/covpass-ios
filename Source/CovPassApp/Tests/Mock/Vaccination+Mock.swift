//
//  Vaccination+Mock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon

extension Vaccination {
    static func mock() -> Vaccination {
        .init(
            tg: "840539006",
            vp: "1119305005",
            mp: "EU/1/20/1528",
            ma: "ORG-100001699",
            dn: 1,
            sd: 3,
            dt: .init(timeIntervalSinceReferenceDate: 0),
            co: "DE",
            is: "Robert Koch-Institut",
            ci: "01DE/84503/DXSGWLWL40SU8ZFKIYIBK39A3#S"
        )
    }
}
