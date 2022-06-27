//
//  ShareRevocationPDFViewController.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

class ShareRevocationPDFViewController: UIActivityViewController {
    init(viewModel: ShareRevocationPDFViewModelProtocol) {
        super.init(
            activityItems: [viewModel.fileURL],
            applicationActivities: nil
        )
        modalTransitionStyle = .coverVertical
        completionWithItemsHandler = { _, completed, _, activityError in
            viewModel.handleActivityResult(
                completed: completed,
                activityError: activityError
            )
        }
    }
}
