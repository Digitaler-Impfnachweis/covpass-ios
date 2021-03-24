//
//  Base45Encoder.swift
//  
//
//  Created by Gabriela Secelean on 23.03.2021.
//

import Foundation

class Base45Encoder {
    private let base45Table: Dictionary<Int, String> = [
        0: "0", 1: "1", 2: "2", 3: "3", 4: "4", 5: "5", 6: "6", 7: "7", 8: "8", 9: "9", 10: "A", 11: "B",
        12: "C", 13: "D", 14: "E", 15: "F", 16: "G", 17: "H", 18: "I", 19: "J", 20: "K", 21: "L", 22: "M",
        23: "N", 24: "O", 25: "P", 26: "Q", 27: "R", 28: "S", 29: "T", 30: "U", 31: "V", 32: "W", 33: "X",
        34: "Y", 35: "Z", 36: " ", 37: "$", 38: "%", 39: "*", 40: "+", 41: "-", 42: ".", 43: "/", 44: ":"
    ]

    func encode(_ int8Array: [Int8]) -> String {
        let int16Array = sequence(state: int8Array.makeIterator(), next: { it in
            it.next().map { ($0, it.next()) }
        }).map { convertToInt16(firstInt: $0, secondInt: $1 ?? 0 ) }
    }

    private func convertToInt16(firstInt: Int8, secondInt: Int8) -> Int16 {
        let bytes: [Int8] = [firstInt, secondInt]

        return Int16(bytes[0]) << 8 | Int16(bytes[1])
    }
}
