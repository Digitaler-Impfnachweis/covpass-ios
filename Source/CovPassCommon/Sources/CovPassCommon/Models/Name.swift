//
//  Name.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public class Name: Codable {
    /// The given name(s) of the person addressed in the certificate
    public var gn: String?
    /// The family or primary name(s) of the person addressed in the certificate
    public var fn: String?
    /// The given name(s) of the person transliterated
    public var gnt: String?
    /// The family name(s) of the person transliterated
    public var fnt: String

    /// The full name of the person
    public var fullName: String {
        if let gn = gn, let fn = fn {
            return "\(gn) \(fn)"
        }
        if let gnt = gnt {
            return "\(gnt) \(fnt)"
        }
        return fnt
    }

    public var fullNameTransliterated: String {
        if let gnt = gnt {
            return "\(gnt) \(fnt)"
        }
        return fnt
    }

    public var fullNameReverse: String {
        if let gn = gn, let fn = fn {
            return "\(fn), \(gn)"
        }
        if let gnt = gnt {
            return "\(fnt), \(gnt)"
        }
        return fnt
    }

    public var fullNameTransliteratedReverse: String {
        if let gnt = gnt {
            return "\(fnt), \(gnt)"
        }
        return fnt
    }

    enum CodingKeys: String, CodingKey {
        case gn
        case fn
        case gnt
        case fnt
    }

    public init(gn: String? = nil, fn: String? = nil, gnt: String? = nil, fnt: String) {
        self.gn = gn
        self.fn = fn
        self.gnt = gnt
        self.fnt = fnt
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        gn = try? values.decodeTrimmedString(forKey: .gn)
        fn = try? values.decodeTrimmedString(forKey: .fn)
        gnt = try? values.decodeTrimmedString(forKey: .gnt)
        fnt = try values.decodeTrimmedString(forKey: .fnt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(gn, forKey: .gn)
        try container.encode(fn, forKey: .fn)
        try container.encode(gnt, forKey: .gnt)
        try container.encode(fnt, forKey: .fnt)
    }
}

extension Name: Equatable {
    public static func == (lhs: Name, rhs: Name) -> Bool {
        let fntMatches = lhs.fnt.matches(with: rhs.fnt)
        guard fntMatches else {
            return false
        }
        if let lhsGnt = lhs.gnt, let rhsGnt = rhs.gnt {
            return lhsGnt.matches(with: rhsGnt)
        }
        return true
    }
}

private extension String {
    private func icaoSplitting() -> [String] {
        let stringWithSingleChevron = replacingOccurrences(of: "<<", with: "<")
        let components = stringWithSingleChevron.split(separator: "<")
        let stringComponents = components.map { String($0) }

        return stringComponents
    }

    func matches(with icaoName: String) -> Bool {
        let components1 = icaoSplitting().trimming().removingDrTitle()
        let components2 = icaoName.icaoSplitting().trimming().removingDrTitle()
        let componentsSet1 = Set(components1)
        let componentsSet2 = Set(components2)

        return !componentsSet1.isDisjoint(with: componentsSet2)
    }
}

private extension Array where Element == String {
    func removingDrTitle() -> [Element] {
        filter { $0 != "DR" }
    }

    func trimming() -> [String] {
        map { $0.trimmingCharacters(in: .whitespaces) }
    }
}
