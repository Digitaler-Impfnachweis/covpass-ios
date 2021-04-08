//
//  Encoder.swift
//  CBORSwift
//
//  Created by Hassan Shahbazi on 5/2/18.
//  Copyright © 2018 Hassan Shahbazi. All rights reserved.
//

import Foundation

class Encoder: NSObject {
    class func prepareByteArray(major: MajorType, measure: Int) -> [UInt8] {
        var encoded = MajorTypes(major).get().bytes
        
        var rawBytes = [UInt8]()
        prepareHeaderByteArray(bytes: &rawBytes, measure: measure)
        rawBytes.append(contentsOf: measure.decimal_binary)
        encoded.append(contentsOf: [UInt8](rawBytes[3..<rawBytes.count]))
        
        return encoded
    }
    
    class func prepareEncodedResponse(encodedArray: inout [UInt8]) -> String {
        var response = ""
        if encodedArray.count > 64 {
            response = [UInt8](encodedArray[0..<64]).binary_decimal.hex
            encodedArray = [UInt8](encodedArray[64..<encodedArray.count])
        }
        response.append(Data(bytes: encodedArray).binary_decimal.hex)
        return response
    }
    
    class func getIncludedEncodings(item: AnyObject) -> String {
        var data = ""
        data.append(item.encode())
        return data
    }
}

private extension Encoder {
    private class func prepareHeaderByteArray(bytes: inout [UInt8], measure: Int) {
        if measure >= 0 && measure <= 23 {}
        else if measure >= 24 && measure <= UInt8.max { bytes = 24.decimal_binary }
        else if measure >= UInt16.min && measure <= UInt16.max { bytes = 25.decimal_binary }
        else if measure >= UInt32.min && measure <= UInt32.max { bytes = 26.decimal_binary }
        else if measure >= UInt64.min && measure <= UInt64.max { bytes = 27.decimal_binary }
    }
}

extension NSObject: Any {
    @objc internal func encode() -> String {
        return self.encode()
    }
}

extension NSNumber {
    @objc override func encode() -> String {
        let major: MajorType = (self.intValue < 0) ? .major1 : .major0
        let measure = (self.intValue < 0) ? (self.intValue * -1) - 1 : self.intValue

        var encodedArray = Encoder.prepareByteArray(major: major, measure: measure)
        let response = Encoder.prepareEncodedResponse(encodedArray: &encodedArray)
        
        return response
    }
}

extension NSString {
    @objc override func encode() -> String {
        let encodedArray = Encoder.prepareByteArray(major: .major3, measure: self.length)
        let headerData  = Data(bytes: encodedArray).binary_decimal.hex
        let strData     = Data(bytes: self.ascii_bytes).hex
        
        return headerData.appending(strData)
    }
}

extension NSArray {
    @objc override func encode() -> String {
        let encodedArray = Encoder.prepareByteArray(major: .major4, measure: self.count)
        return (Data(bytes: encodedArray).binary_decimal.hex).appending(getItemsEncoding())
    }
    
    private func getItemsEncoding() -> String {
        var data = ""
        for item in self {
            data.append(Encoder.getIncludedEncodings(item: item as AnyObject))
        }
        return data
    }
}

extension NSDictionary {
    @objc override func encode() -> String {
        let encodedArray = Encoder.prepareByteArray(major: .major5, measure: self.allKeys.count)
        return (Data(bytes: encodedArray).binary_decimal.hex).appending(getItemsEncoding())
    }
    
    private func getItemsEncoding() -> String {
        var data = ""
        var key_value = [String:String]()
        for (key, value) in self {
            key_value[Encoder.getIncludedEncodings(item: key as AnyObject)] = Encoder.getIncludedEncodings(item: value as AnyObject)
        }
        
        let dic = key_value.valueKeySorted
        for item in dic {
            data.append(item.0)
            data.append(item.1)
        }
        return data
    }
}

extension NSData {
    @objc override func encode() -> String {
        let data = self as Data
        let encodedArray = Encoder.prepareByteArray(major: .major2, measure: data.count)
        return Data(bytes: encodedArray).binary_decimal.hex
    }
}
