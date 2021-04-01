//
//  Compundable.swift
// 
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public typealias CompoundableView = Compoundable & UIView

public protocol Compoundable {
    /// Property which returns the height of a component which conforms to the Compoundable protocol
    var contentHeight: CGFloat { get }
    /// Use this property in order to set and get the compoundDelegate of a component which conforms to the Compoundable protocol
    var compoundDelegate: CompoundableUpdate? { get set }
}

extension Compoundable where Self: CompoundableView {
    /// Returns the height of the current instance of type CompoundableView
    public var contentHeight: CGFloat {
        return frame.size.height
    }
}
