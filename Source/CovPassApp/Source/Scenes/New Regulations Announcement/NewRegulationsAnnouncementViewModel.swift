//
//  NewRegulationsAnnouncementViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit

private enum Constants {
    static let header = "infschg_info_title".localized
    static let copyText1 = "infschg_info_copy_1".localized
    static let subtitle = "infschg_info_copy_2".localized
    static let copyText2 = "infschg_info_copy_3".localized
    static let buttonTitle = "infschg_info_button".localized
}

final class NewRegulationsAnnouncementViewModel: NewRegulationsAnnouncementViewModelProtocol {
    let header = Constants.header
    let illustration: UIImage = .illustrationImpfschutzgesetz
    let copyText1 = Constants.copyText1
    let subtitle = Constants.subtitle
    let copyText2 = Constants.copyText2
    let buttonTitle = Constants.buttonTitle

    private let resolver: Resolver<Void>

    init(resolver: Resolver<Void>) {
        self.resolver = resolver
    }

    func close() {
        resolver.fulfill_()
    }
}
