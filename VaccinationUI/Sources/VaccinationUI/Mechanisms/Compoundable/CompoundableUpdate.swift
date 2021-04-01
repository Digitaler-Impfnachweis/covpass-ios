//
//  CompoundableUpdate.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

/// Use this ptotocol in order to receive update calls from compoundable elements
public protocol CompoundableUpdate: AnyObject {
    /// This function should be called when a layout change for the compoundable elements is made
    func compoundableDidUpdate()
}
