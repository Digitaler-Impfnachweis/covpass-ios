//
//  ValidationFailedViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import PromiseKit

private enum Constants {
    enum Keys {
        static let title = "warning_unknown_provider_title".localized
        static let description = "warning_unknown_provider_copy".localized
        static let accept = "warning_unknown_provider_box_button_primary".localized
        static let cancel = "warning_unknown_provider_box_button_secondary".localized
        static let hintTitle = "warning_unknown_provider_box_title".localized
        static let bulletOne = "warning_unknown_provider_box_item_1".localized
        static let bulletTwo = "warning_unknown_provider_box_item_2".localized
        static let bulletThree = "warning_unknown_provider_box_item_3".localized
        static let bulletFour = "warning_unknown_provider_box_item_4".localized
    }
}

protocol ValidationFailedViewModelProtocol {
    var title: String { get }
    var description: String { get }
    var acceptButtonText: String { get }
    var cancelButtonText: String { get }
    var hintTitle: String { get }
    var hintText: NSAttributedString { get }
    func continueProcess()
    func cancelProcess()
}

struct ValidationFailedViewModel: ValidationFailedViewModelProtocol {
    private let resolvable: Resolver<Bool>
    private let ticket: ValidationServiceInitialisation
    var title: String { Constants.Keys.title }
    var description: String { String(format: Constants.Keys.description, ticket.serviceProvider) }
    var acceptButtonText: String { Constants.Keys.accept }
    var cancelButtonText: String { Constants.Keys.cancel }
    var hintTitle: String { Constants.Keys.hintTitle }
    var hintText: NSAttributedString {
        let bulletOne = Constants.Keys.bulletOne.styledAs(.body)
        let bulletTwo = Constants.Keys.bulletTwo.styledAs(.body)
        let bulletThree = Constants.Keys.bulletThree.styledAs(.body)
        let bulletFour = Constants.Keys.bulletFour.styledAs(.body)
        return NSAttributedString.toBullets([bulletOne,
                                             bulletTwo,
                                             bulletThree,
                                             bulletFour])
    }

    internal init(resolvable: Resolver<Bool>, ticket: ValidationServiceInitialisation) {
        self.resolvable = resolvable
        self.ticket = ticket
    }

    func continueProcess() {
        resolvable.fulfill(true)
    }

    func cancelProcess() {
        resolvable.fulfill(false)
    }
}
