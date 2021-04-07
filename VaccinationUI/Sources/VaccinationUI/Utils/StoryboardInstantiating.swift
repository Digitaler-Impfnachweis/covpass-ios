//
//  StoryboardInstantiating.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit

public protocol StoryboardInstantiating: class {
    /// Name of the storyboard where the view controller is in
    static var storyboardName: String { get }

    /// The view controller identifier that is defined in the storyboard
    static var identifier: String { get }

    /// Name of the bundle where the storyboard is in
    static var bundle: Bundle { get }

    /// Create an instance of this view controller with the given bundle
    ///
    /// - Parameters:
    ///   - bundle: The bundle where the storyboard is in
    /// - Returns: Self
    static func createFromStoryboard(bundle: Bundle) -> Self

    /// Create an instance of this view controller with the given name and bundle
    ///
    /// - Parameters:
    ///   - name: The storyboard name
    ///   - bundle: The bundle where the storyboard is in
    /// - Returns: Self
    static func createFromStoryboard(_ name: String, bundle: Bundle) -> Self
}

public extension StoryboardInstantiating where Self: UIViewController {
    static var identifier: String {
        return String(describing: self)
    }

    static var bundle: Bundle {
        return Bundle.module
    }

    static func createFromStoryboard(bundle: Bundle = bundle) -> Self {
        return UIStoryboard.createViewController(in: storyboardName, identifier: identifier, bundle: bundle)
    }

    static func createFromStoryboard(_ name: String, bundle: Bundle = bundle) -> Self {
        return UIStoryboard.createViewController(in: name, identifier: identifier, bundle: bundle)
    }
}

public extension UIStoryboard {
    /// Create an instance of this view controller
    ///
    /// - Parameters:
    ///   - storyboard: The storyboard name
    ///   - identifier: The view controller  name
    ///   - bundle: The bundle where the storyboard is in
    /// - Returns: UIViewController
    static func createViewController<T: UIViewController>(in storyboard: String, identifier: String = String(describing: T.self), bundle: Bundle = Bundle(for: T.self)) -> T {
        let storyboard = UIStoryboard(name: storyboard, bundle: bundle)
        guard let vc = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("Could not create a UIViewController from the storyboard: \(storyboard)")
        }
        return vc
    }

    /// Create the initial view controller of the given storyboard
    ///
    /// - Parameters:
    ///   - storyboard: The storyboard name
    ///   - bundle: The bundle where the storyboard is in
    /// - Returns: UIViewController
    static func instantiateInitialViewController<T: UIViewController>(in storyboard: String, bundle: Bundle = Bundle(for: T.self)) -> T {
        let storyboard = UIStoryboard(name: storyboard, bundle: bundle)
        guard let vc = storyboard.instantiateInitialViewController() as? T else {
            fatalError("Could not create the initial UIViewController from the storyboard: \(storyboard)")
        }
        return vc
    }
}
