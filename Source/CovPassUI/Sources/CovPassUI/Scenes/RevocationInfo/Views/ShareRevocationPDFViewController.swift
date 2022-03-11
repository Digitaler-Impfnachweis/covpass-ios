//
//  ShareRevocationPDFViewController.swift
//  
//
//  Created by Thomas Kuleßa on 10.03.22.
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
