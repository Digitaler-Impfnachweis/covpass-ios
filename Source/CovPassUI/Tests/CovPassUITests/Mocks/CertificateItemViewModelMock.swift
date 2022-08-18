//
//  CertificateItemViewModelMock.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import UIKit

struct CertificateItemViewModelMock: CertificateItemViewModel {
    var icon: UIImage = UIImage()
    var iconColor: UIColor = .purple
    var iconBackgroundColor: UIColor = .yellow
    var title = ""
    var titleAccessibilityLabel: String? = nil
    var subtitle = ""
    var subtitleAccessibilityLabel: String? = nil
    var info = ""
    var infoAccessibilityLabel: String? = nil
    var info2: String? = nil
    var info2AccessibilityLabel: String? = nil
    var statusIcon: UIImage? = nil
    var statusIconAccessibilityLabel: String? = nil
    var statusIconHidden = false
    var activeTitle: String? = nil
    var certificateItemIsSelectableAccessibilityLabel = ""
}
