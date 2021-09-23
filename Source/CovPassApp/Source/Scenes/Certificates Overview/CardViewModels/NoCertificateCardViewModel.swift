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

    var reuseIdentifier: String {
        "\(NoCertificateCollectionViewCell.self)"
    }

    var backgroundColor: UIColor {
        .backgroundSecondary20
    }

    var title: String {
        "vaccination_start_screen_note_title".localized
    }

    var subtitle: String {
        "vaccination_start_screen_note_message".localized
    }

    var image: UIImage {
        .noCertificate
    }

    var iconTintColor: UIColor {
        return .neutralWhite
    }

    var textColor: UIColor {
        return .neutralWhite
    }
}
