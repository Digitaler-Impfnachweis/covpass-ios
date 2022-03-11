//
//  Base45Coder.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public enum Base45CodingError: Error, ErrorCode {
    case base45Decoding

    public var errorCode: Int {
        switch self {
        case .base45Decoding:
            return 301
        }
    }
}

public enum Base45Coder {
    private static let base45Table: [Int: String] = [
        0: "0", 1: "1", 2: "2", 3: "3", 4: "4", 5: "5", 6: "6", 7: "7", 8: "8", 9: "9", 10: "A", 11: "B",
        12: "C", 13: "D", 14: "E", 15: "F", 16: "G", 17: "H", 18: "I", 19: "J", 20: "K", 21: "L", 22: "M",
        23: "N", 24: "O", 25: "P", 26: "Q", 27: "R", 28: "S", 29: "T", 30: "U", 31: "V", 32: "W", 33: "X",
        34: "Y", 35: "Z", 36: " ", 37: "$", 38: "%", 39: "*", 40: "+", 41: "-", 42: ".", 43: "/", 44: ":"
    ]

    /// This method encodes an array of unsigned 8 bit integers representing ascii values to a String in base45
    /// - parameter int8Array: the array to be encoded
    /// - returns: a String in base45
    public static func encode(_ int8Array: [UInt8]) -> String {
        return sequence(state: int8Array.makeIterator(), next: { it in
            it.next().map { ($0, it.next()) }
        }).map { Base45Coder.mapToBase45Character(firstInt: $0, secondInt: $1) }.joined()
    }

    /// This method decodes a base45 String back into an array of UInt8 ascii values
    /// - parameter payload: a String represented in base45
    /// - returns: an array of unsigned 8 bit integers representing ascii values
    public static func decode(_ payload: String) throws -> [UInt8] {
        var base45Values = [UInt8]()

        for character in payload {
            if let key = Base45Coder.base45Table.getKeys(for: String(character)).first {
                base45Values.append(UInt8(key))
            }
        }

        return try base45Values.chunked(into: 3).flatMap { try mapToCBOR($0) }
    }

    // MARK: - Private helper methods

    /// This method takes two 8 bit integer values, converts them into a 16 bit value and calls the `expand` method to receive a base45 character
    /// - parameter firstInt: an unsignd 8 bit integer
    /// - parameter secondInt: the second unsigned 8 bit integer, an optional value which will be ignored in case it has the value `nil`
    /// - returns: a base45 String
    private static func mapToBase45Character(firstInt: UInt8, secondInt: UInt8?) -> String {
        guard let lastInt = secondInt else {
            return expand(number: UInt16(firstInt), by: 2)
        }
        let int16Value = UInt16(firstInt) << 8 | UInt16(lastInt)

        return expand(number: int16Value, by: 3)
    }

    /// Expects an array of length either 3 or 2 of base45 unsigned 8 bit integer values which will then be converted to a 16 bit value through the `reduce` method, afterwards being splitted in two or three unsigned 8 bit integers
    /// depending on the initial length of the array
    /// - parameter sequence: an array of unsigned 8 bit integers of length 3 or 2
    /// - returns: an array with length 2 or 1 of unsigned 8 bit integer values, depending on the length of `sequence`
    private static func mapToCBOR(_ sequence: [UInt8]) throws -> [UInt8] {
        guard sequence.count == 3 else { return [UInt8(try reduce(array: sequence) & 0x00FF)] }

        let int16Value = try reduce(array: sequence)
        return [UInt8(int16Value >> 8), UInt8(int16Value & 0x00FF)]
    }

    /// Expands an unsigned 16 bit integer into a string composed of base45 characters
    /// - parameter number: the 16 bit integer number to be mapped to base45 characters
    /// - parameter count: an integer establishing the number of characters the 16 bit value should be split into
    /// - returns: a base45 String
    private static func expand(number: UInt16, by count: Int) -> String {
        var result = ""
        var integerNumber = Int(number)

        for _ in 0 ..< count {
            let base45Character = base45Table[integerNumber % 45] ?? ""
            result += base45Character
            integerNumber /= 45
        }

        return result
    }

    /// Reduces an array of length 3 or 2 of base45 integers to an unsigned 16 bit value
    /// - parameter array: the base45 integer array to be reduced to a UInt16 value
    /// - returns: The unsigned 16 bit value resulted from compressing the received array
    private static func reduce(array: [UInt8]) throws -> UInt16 {
        var result: UInt16 = 0

        for count in 0 ..< array.count {
            let resMultiply = UInt16(array[count]).multipliedReportingOverflow(by: UInt16(pow(45, Double(count))))
            if resMultiply.overflow { throw Base45CodingError.base45Decoding }
            let resAdd = result.addingReportingOverflow(resMultiply.partialValue)
            if resAdd.overflow { throw Base45CodingError.base45Decoding }
            result = resAdd.partialValue
        }

        return result
    }
}
