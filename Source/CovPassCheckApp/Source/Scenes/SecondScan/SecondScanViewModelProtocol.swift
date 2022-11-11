//
//  SecondScanViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

protocol SecondScanViewModelProtocol {
    var delegate: ViewModelDelegate? { get set }
    var title: String { get }
    var subtitle: String { get }
    var thirdScanViewIsHidden: Bool { get }
    var firstScanTitle: String { get }
    var firstScanSubtitle: String { get }
    var firstScanIcon: UIImage { get }
    var secondScanTitle: String { get }
    var secondScanSubtitle: String { get }
    var secondScanIcon: UIImage { get }
    var thirdScanTitle: String { get }
    var thirdScanSubtitle: String { get }
    var thirdScanIcon: UIImage { get }
    var hintTitle: String { get }
    var hintSubtitle: String { get }
    var hintImage: UIImage { get }
    var scanNextButtonTitle: String { get }
    var startOverButtonTitle: String { get }
    var countdownTimerModel: CountdownTimerModel { get }
    func startOver()
    func scanNext()
    func cancel()
}
