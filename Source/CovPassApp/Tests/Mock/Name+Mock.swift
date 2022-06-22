//
//  Name+Mock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon

extension Name {
    static func name1() -> Name {
        .init(gn: "Max", fn: "Mustermann", gnt: nil, fnt: "MUSTERMANN")
    }

    static func name2() -> Name {
        .init(gn: "Leila", fn: "Mustermann", gnt: nil, fnt: "MUSTERMANN")
    }

    static func name3() -> Name {
        .init(gn: "Amira", fn: "Mustermann", gnt: nil, fnt: "MUSTERMANN")
    }
}
