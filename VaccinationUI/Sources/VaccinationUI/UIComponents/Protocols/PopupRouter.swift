
//
//  PopupRouter.swift
//
//
//   Copyright © 2018 IBM. All rights reserved.
//

import Foundation
import UIKit

public protocol PopupRouter {
    func presentPopup(onTopOf viewController: UIViewController)
}
