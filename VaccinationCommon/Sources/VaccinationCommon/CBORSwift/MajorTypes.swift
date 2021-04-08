//
//  MajorTypes.swift
//  CBORSwift
//
//  Created by Hassan Shahbazi on 5/2/18.
//  Copyright © 2018 Hassan Shahbazi. All rights reserved.
//

import Foundation

enum MajorType: String {
    case major0 = "000" //unsigned integer
    case major1 = "001" //negative integer
    case major2 = "010" //byte string
    case major3 = "011" //text string
    case major4 = "100" //array of data items
    case major5 = "101" //map of pairs of data items (dictionary)
    case major6 = "110" //optional semantic tagging of other major types
    case major7 = "111" //floating point numbers and simple data types
}

class MajorTypes: NSObject {
    private var type: MajorType?
    
    override init() {
        super.init()
    }
    
    init(_ type: MajorType) {
        super.init()
        self.type = type
    }
    
    public func set(type: MajorType) {
        self.type = type
    }
    
    public func get() -> Data {
        return Data(bytes: prepareBits())
    }
    
    public func identify(_ type: [UInt8]) -> MajorType? {
        var typeStr = ""
        for bit in type[0..<3] {
            typeStr.append("\(bit)")
        }
        return MajorType(rawValue: typeStr)
    }
    
    private func prepareBits() -> [UInt8] {
        if let bits = type?.rawValue.bytes {
            return [UInt8](bits[bits.count-3..<bits.count])
        }
        return [UInt8](repeating: 0, count: 3)
    }
}
