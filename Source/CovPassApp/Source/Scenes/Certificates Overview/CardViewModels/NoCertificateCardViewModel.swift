//
//  NoCertificateCardViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

struct NoCertificateCardViewModel: NoCertificateCardViewModelProtocol {
    // MARK: - Internal Properties

    var delegate: ViewModelDelegate?

    let reuseIdentifier: String = "\(NoCertificateCollectionViewCell.self)"

    let backgroundColor: UIColor = .backgroundSecondary20

    var title: String {
        Date().passedFirstOfJanuary2024 ? "vaccination_start_screen_note_title_after_july".localized : "vaccination_start_screen_note_title".localized
    }

    var subtitle: String { Date().passedFirstOfJanuary2024 ? "vaccination_start_screen_note_message_after_july".localized : "vaccination_start_screen_note_message".localized }

    let image: UIImage = .noCertificate

    let iconTintColor: UIColor = .neutralWhite

    let textColor: UIColor = .neutralWhite

    let showNotification: Bool = false
}
