//
//  QRCoderProtocol.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

public protocol QRCoderProtocol {
    /// Decodes the payload with `base45`, decompresses it with `zlib`, parses the resulted COSE object and CBOR decodes it afterwards
    /// - parameter payload: the String read from the QR Code
    /// - parameter completion: the fallback in case an error occurs
    /// - returns a readable String
    func parse(_ payload: String, completion: ((Error) -> Void)?) -> String?
}
