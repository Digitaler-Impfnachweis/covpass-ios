//
//  Base45Encoder.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

class Base45Encoder {
    private let base45Table: Dictionary<Int, String> = [
        0: "0", 1: "1", 2: "2", 3: "3", 4: "4", 5: "5", 6: "6", 7: "7", 8: "8", 9: "9", 10: "A", 11: "B",
        12: "C", 13: "D", 14: "E", 15: "F", 16: "G", 17: "H", 18: "I", 19: "J", 20: "K", 21: "L", 22: "M",
        23: "N", 24: "O", 25: "P", 26: "Q", 27: "R", 28: "S", 29: "T", 30: "U", 31: "V", 32: "W", 33: "X",
        34: "Y", 35: "Z", 36: " ", 37: "$", 38: "%", 39: "*", 40: "+", 41: "-", 42: ".", 43: "/", 44: ":"
    ]

    func encode(_ int8Array: [UInt8]) -> String {
        var encodedString = ""
        let _ = sequence(state: int8Array.makeIterator(), next: { it in
            it.next().map { ($0, it.next()) }
        }).map { encodedString += mapToBase45Character(firstInt: $0, secondInt: $1) }

        return encodedString
    }

    func decode(_ payload: String) -> [UInt8] {
        var base45Values = [UInt8]()
        var result = [UInt8]()

        for character in payload {
            if let key = base45Table.getKey(for: String(character)) {
                base45Values.append(UInt8(key))
            }
        }

        base45Values.chunked(into: 3).forEach { result.append(contentsOf: mapToCBOR($0)) }

        return result
    }

    private func mapToBase45Character(firstInt: UInt8, secondInt: UInt8?) -> String {
        guard let lastInt = secondInt else {
            return expand(number: UInt16(firstInt), by: 2)
        }
        let int16Value = UInt16(firstInt) << 8 | UInt16(lastInt)

        return expand(number: int16Value, by: 3)
    }

    private func mapToCBOR(_ sequence: [UInt8]) -> [UInt8] {
        guard sequence.count == 3 else { return [UInt8(reduce(array: sequence) & 0x00ff)] }

        let int16Value = reduce(array: sequence)
        return [UInt8(int16Value >> 8), UInt8(int16Value & 0x00ff)]
    }

    private func expand(number: UInt16, by count: Int) -> String {
        var result = ""
        var integerNumber = Int(number)

        for _ in 0..<count {
            result += base45Table[integerNumber % 45] ?? ""
            integerNumber /= 45
        }

        return result
    }

    private func reduce(array: [UInt8]) -> UInt16 {
        var result: UInt16 = 0

        for count in 0..<array.count {
            result += UInt16(array[count]) * UInt16(pow(45, Double(count)))
        }

        return result
    }
}
