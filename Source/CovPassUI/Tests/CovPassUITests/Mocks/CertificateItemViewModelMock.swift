//
//  CertificateItemViewModelMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import UIKit

struct CertificateItemViewModelMock: CertificateItemViewModel {
    var icon: UIImage = .init()
    var iconColor: UIColor = .purple
    var iconBackgroundColor: UIColor = .yellow
    var title = ""
    var titleAccessibilityLabel: String?
    var subtitle = ""
    var subtitleAccessibilityLabel: String?
    var info = ""
    var infoAccessibilityLabel: String?
    var info2: String?
    var info2AccessibilityLabel: String?
    var statusIcon: UIImage?
    var statusIconAccessibilityLabel: String?
    var statusIconHidden = false
    var activeTitle: String?
    var certificateItemIsSelectableAccessibilityLabel = ""
}
