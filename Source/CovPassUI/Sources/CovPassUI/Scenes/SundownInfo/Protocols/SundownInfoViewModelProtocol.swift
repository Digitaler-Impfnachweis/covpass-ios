//
//  SundownInfoViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

protocol SundownInfoViewModelProtocol: CancellableViewModelProtocol {
    var image: UIImage { get }
    var imageDescription: String { get }
    var title: String { get }
    var copy: String { get }
    var subtitle: String { get }
    var bulletPoints: NSAttributedString { get }
    func cancel()
}
