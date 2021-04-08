//
//  CoseSign1Encoder.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

//struct CoseSignature {
//    var protected: [UInt8]
//    var unprotected: Any?
//    var signature: [UInt8]
//
//    init(protected: [UInt8], unprotected: Any?, signature: [UInt8]) {
//        self.protected = protected
//        self.unprotected = unprotected
//        self.signature = signature
//    }
//}

struct CoseSign1Message {
    var protected: [UInt8]
    var unprotected: Any?
    var payload: [UInt8]
    var signatures: [UInt8]

    init(protected: [UInt8], unprotected: Any?, payload: [UInt8], signatures: [UInt8]) {
        self.protected = protected
        self.unprotected = unprotected
        self.payload = payload
        self.signatures = signatures
    }
}

class CodeSign1Encoder {
    static func parse(_ decompressedData: Data) -> CoseSign1Message? {
        guard let cborArray = [UInt8](decompressedData).decode() as? NSArray, cborArray.count == 4 else { return nil }

        return CoseSign1Message(protected: (cborArray[0] as? [UInt8]) ?? [], unprotected: cborArray[1], payload: (cborArray[2] as? [UInt8]) ?? [], signatures: (cborArray[3] as? [UInt8]) ?? [])
    }
}
