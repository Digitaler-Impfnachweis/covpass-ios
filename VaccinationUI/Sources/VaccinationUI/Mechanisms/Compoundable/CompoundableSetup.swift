//
//  CompoundableSetup.swift
// 
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

/// Use this protocol where compoundable mechanism needs setup
public protocol CompoundableSetup: class {
    /// Enables compoundable mechanism
    func compoundingSetup()
    /// Disables compoundable mechanism
    func compoundingUnSetup()
}

// MARK: - CompoundableSetup

extension CompoundableSetup where Self: UIViewController, Self: CompoundableUpdate {
    /// For each Compoundable view from the current UIViewController, sets its compoundDelegate to the current UIViewController instance
    public func compoundingSetup() {
        for view in view.subviews where view is Compoundable {
            guard var compound = view as? Compoundable else { continue }
            compound.compoundDelegate = self
        }
    }

    /// For each Compoundable view from the current UIViewController, set its compoundDelegate to nil
    public func compoundingUnSetup() {
        for view in view.subviews where view is Compoundable {
            guard var compound = view as? Compoundable else { continue }
            compound.compoundDelegate = nil
        }
    }
}
