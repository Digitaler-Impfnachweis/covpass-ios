//
//  NSDictionary+CertificateRevocationMocks.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension NSDictionary {
    static func validKidListResponse() -> Self {
        let dictionary: Self = [
            "f5c5970c3039d854": [
                "0a": 3,
                "0b": 2,
                "0c": 1
            ],
            "ABCD": [
                "0b": 64,
                "0c": 18,
                "0a": 2
            ],
            "ff": [
                "0c": 1,
                "0a": 0
            ]
        ]
        return dictionary
    }

    static func invalidKidListResponse() -> Self {
        let dictionary: Self = [
            0xf5c59: [
                0x0a: 3,
                0x0b: 2,
                0x0c: 1
            ]
        ]
        return dictionary
    }

    static func kidListResponseSignatureIsSecond() -> Self {
        let dictionary: Self = [
            "f5c5970c3039d854": [
                "0a": 2,
                "0b": 3,
                "0c": 1
            ]
        ]
        return dictionary
    }

    static func kidListResponseUCIHasPriority() -> Self {
        let dictionary: Self = [
            "f5c5970c3039d854": [
                "0a": 1,
                "0b": 3
            ]
        ]
        return dictionary
    }

    static func kidListResponseUCICountryHasPriority() -> Self {
        let dictionary: Self = [
            "f5c5970c3039d854": [
                "0a": 1,
                "0b": 2,
                "0c": 3
            ]
        ]
        return dictionary
    }

    static func validIndexListResponse() -> Self {
        let dictionary: Self = [
            "a6": [
                123.456,
                5,
                [
                    "b8": [456.789, 6]
                ]
            ],
            "bc": [
                123.456,
                7,
                [
                    "54": [123.456, 2]
                ]
            ],
            "97": [
                123.456,
                2,
                [
                    "22": [321.123, 1]
                ]
            ]
        ]
        return dictionary
    }

    static func indexListResponseOnlySignatureHash() -> Self {
        let dictionary: Self = [
            "a6": [
                123.456,
                5,
                [
                    "b8": [456.789, 6]
                ]
            ]
        ]
        return dictionary
    }

    static func invalidIndexListResponse() -> Self {
        let dictionary: Self = [
            "a6": [
                123.456,
                5,
                [
                    "INVALID": [456.789, 6]
                ]
            ]
        ]
        return dictionary
    }

}
