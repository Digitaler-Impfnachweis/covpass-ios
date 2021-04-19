//
//  BaseCertifiateConfiguration.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

public class BaseCertifiateConfiguration {
    public var backgroundColor: UIColor?
    public var identifier: String
    public init(backgroundColor: UIColor?, identifer: String) {
        self.backgroundColor = backgroundColor
        self.identifier = identifer
    }
}
