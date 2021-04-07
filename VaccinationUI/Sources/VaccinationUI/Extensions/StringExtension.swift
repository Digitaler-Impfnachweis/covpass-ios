//
//  StringExtension.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

extension String {
    public var boldParts: [String]? {
        do {
            let regex = try NSRegularExpression(pattern: "\\[b\\](.*?)\\[\\/b\\]")
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))

            return results.map { nsString.substring(with: $0.range(at: 1)) }
        } catch {
            return nil
        }
    }
}

extension String {
    func UInsRange(from range: Range<Index>) -> NSRange {
        let location = distance(from: startIndex, to: range.lowerBound)
        let length = distance(from: range.lowerBound, to: range.upperBound)

        return NSRange(location: location, length: length)
    }
}
