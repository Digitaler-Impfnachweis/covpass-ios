//
//  ScanCountWarningViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit
import UIKit

private enum Constants {
    enum Keys {
        static let title = "certificate_add_warning_maximum_title".localized
        static let description = "certificate_add_warning_maximum_copy_ios".localized
        static let accept = "certificate_add_warning_maximum_button_primary".localized
        static let cancel = "certificate_add_warning_maximum_button_secondary".localized
    }

    enum Images {
        static let headerImage = UIImage.illustration2
    }

    enum Accessibility {
        static let openPage = "accessibility_certificate_add_warning_maximum_announce".localized
        static let imageDescription = "accessibility_certificate_add_warning_maximum_image".localized
    }
}

struct ScanCountWarningViewModel: ScanCountWarningViewModelProtocol {
    private let resolvable: Resolver<Bool>?
    private let router: ScanCountRouterProtocol?

    var headerImage: UIImage { Constants.Images.headerImage }
    var title: String { Constants.Keys.title }
    var description: String { Constants.Keys.description }
    var acceptButtonText: String { Constants.Keys.accept }
    var cancelButtonText: String { Constants.Keys.cancel }
    var accOpenPage: String { Constants.Accessibility.openPage }
    var accImageDescription: String { Constants.Accessibility.imageDescription }

    internal init(router: ScanCountRouterProtocol?,
                  resolvable: Resolver<Bool>?) {
        self.resolvable = resolvable
        self.router = router
    }

    func continueProcess() {
        resolvable?.fulfill(true)
    }

    func cancelProcess() {
        resolvable?.fulfill(false)
    }

    func routeToSafari(url: URL) {
        router?.routeToSafari(url: url)
    }
}
