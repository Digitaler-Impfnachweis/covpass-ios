//
//  CBOR.swift
//  CBORSwift
//
//  Created by Hassan Shahbazi on 5/2/18.
//  Copyright © 2018 Hassan Shahbazi. All rights reserved.
//

import Foundation

public class CBOR: NSObject {
    
    //MARK:- Encoder
    public class func encode(_ value: NSObject) -> [UInt8]? {
        return value.encode().data?.bytes
    }

    //MARK:- Decoder
    public class func decode(_ value: [UInt8]) -> NSObject? {
        let decoder = Decoder(value)
        return decoder.decode()
    }
}


extension NSObject {
    public func encode() -> [UInt8]? {
        return CBOR.encode(self)
    }
}

extension Array where Element == UInt8 {
    public func decode() -> NSObject? {
        return CBOR.decode(self)
    }
}
