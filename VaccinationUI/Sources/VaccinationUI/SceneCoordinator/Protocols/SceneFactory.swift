//
//  SceneFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

public protocol SceneFactory {
    func make() -> UIViewController
}
