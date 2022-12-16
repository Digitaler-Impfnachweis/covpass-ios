//
//  SecondScanViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

private enum Constant {
    enum Keys {
        static let title = "functional_validation_check_popup_second_scan_title".localized
        static let subtitle = "functional_validation_check_popup_second_scan_subtitle".localized
        static let card1Title = "functional_validation_check_popup_second_scan_blue_card_1_title".localized
        static let card2Title = "functional_validation_check_popup_second_scan_blue_card_2_title".localized
        static let card3Title = "functional_validation_check_popup_second_scan_blue_card_3_title".localized
        static let card1Subtitle = "functional_validation_check_popup_second_scan_blue_card_1_subtitle".localized
        static let card2Subtitle = "functional_validation_check_popup_second_scan_blue_card_2_subtitle".localized
        static let card3Subtitle = "functional_validation_check_popup_second_scan_blue_card_3_subtitle".localized
        static let hintTitle = "functional_validation_check_popup_second_scan_hint_title".localized
        static let hintSubtitle = "functional_validation_check_popup_second_scan_hint_copy".localized
        static let startOverButtonTitle = "technical_validation_check_popup_valid_vaccination_button_1_title".localized
        static let scanNextButtonTitle = "validation_check_popup_valid_vaccination_button_title".localized
    }
}

class SecondScanViewModel: SecondScanViewModelProtocol {
    var title: String = Constant.Keys.title
    var subtitle: String = Constant.Keys.subtitle
    var thirdScanViewIsHidden: Bool { isThirdScan ? false : true }
    var firstScanTitle: String = Constant.Keys.card1Title
    var firstScanSubtitle: String = Constant.Keys.card1Subtitle
    var firstScanIcon: UIImage = .statusPartialCircle
    var secondScanTitle: String = Constant.Keys.card2Title
    var secondScanSubtitle: String { isThirdScan ? Constant.Keys.card1Subtitle : Constant.Keys.card2Subtitle }
    var secondScanIcon: UIImage { isThirdScan ? .statusPartialCircle : .cardEmpty }
    var thirdScanTitle: String = Constant.Keys.card3Title
    var thirdScanSubtitle: String = Constant.Keys.card3Subtitle
    var thirdScanIcon: UIImage = .cardEmpty
    var hintTitle: String = Constant.Keys.hintTitle
    var hintSubtitle: String = Constant.Keys.hintSubtitle
    var hintImage: UIImage = .warning
    var countdownTimerModel: CountdownTimerModel
    var scanNextButtonTitle: String = Constant.Keys.scanNextButtonTitle
    var startOverButtonTitle: String = Constant.Keys.startOverButtonTitle
    var delegate: ViewModelDelegate?
    private var isThirdScan: Bool
    private var token: ExtendedCBORWebToken
    private var secondToken: ExtendedCBORWebToken?
    private var resolver: Resolver<ValidatorDetailSceneResult>

    init(resolver: Resolver<ValidatorDetailSceneResult>,
         token: ExtendedCBORWebToken,
         secondToken: ExtendedCBORWebToken?,
         countdownTimerModel: CountdownTimerModel) {
        self.resolver = resolver
        self.token = token
        self.secondToken = secondToken
        isThirdScan = secondToken != nil
        self.countdownTimerModel = countdownTimerModel
        countdownTimerModel.onUpdate = onCountdownTimerModelUpdate
    }

    private func onCountdownTimerModelUpdate(countdownTimerModel: CountdownTimerModel) {
        if countdownTimerModel.shouldDismiss {
            cancel()
        } else {
            delegate?.viewModelDidUpdate()
        }
    }

    func startOver() {
        resolver.fulfill(.startOver)
    }

    func scanNext() {
        isThirdScan ?
            resolver.fulfill(.thirdScan(token, secondToken!)) :
            resolver.fulfill(.secondScan(token))
    }

    func cancel() {
        resolver.fulfill(.close)
    }
}
