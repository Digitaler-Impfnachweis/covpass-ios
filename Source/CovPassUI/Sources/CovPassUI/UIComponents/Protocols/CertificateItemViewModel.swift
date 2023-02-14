//
//  CertificateItemViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import UIKit

public protocol CertificateItemViewModel {
    var icon: UIImage { get }
    var iconColor: UIColor { get }
    var iconBackgroundColor: UIColor { get }
    var title: String { get }
    var titleAccessibilityLabel: String? { get }
    var subtitle: String { get }
    var subtitleAccessibilityLabel: String? { get }
    var info: String { get }
    var infoAccessibilityLabel: String? { get }
    var info2: String? { get }
    var info2AccessibilityLabel: String? { get }
    var statusIcon: UIImage? { get }
    var statusIconAccessibilityLabel: String? { get }
    var statusIconHidden: Bool { get }
    var activeTitle: String? { get }
    var isNeutral: Bool { get }
    var warningText: String? { get }
    var certificateItemIsSelectableAccessibilityLabel: String { get }
}
