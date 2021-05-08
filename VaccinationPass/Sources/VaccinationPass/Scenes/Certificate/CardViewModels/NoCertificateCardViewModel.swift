//
//  NoCertificateCardViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

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

    func willMoveToWindow() {}
}
