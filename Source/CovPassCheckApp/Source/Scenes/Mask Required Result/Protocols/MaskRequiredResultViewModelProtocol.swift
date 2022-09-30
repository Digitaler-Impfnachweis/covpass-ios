//
//  MaskRequiredResultViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import UIKit

protocol MaskRequiredResultViewModelProtocol: CancellableViewModelProtocol {
    var delegate: ViewModelDelegate? { get set }
    var image: UIImage { get }
    var title: String { get }
    var subtitle: String { get }
    var description: String { get }
    var reasonViewModels: [MaskRequiredReasonViewModelProtocol] { get }
    var secondCertificateReasonViewModel: MaskRequiredSecondCertificateReasonViewModelProtocol { get }
    var buttonTitle: String { get }
    var secondCertificateHintHidden: Bool { get }
    var countdownTimerModel: CountdownTimerModel { get }

    func rescan()
    func scanSecondCertificate()
}
