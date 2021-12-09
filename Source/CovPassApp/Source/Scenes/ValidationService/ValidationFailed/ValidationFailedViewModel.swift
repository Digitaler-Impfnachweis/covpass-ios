//
//  ValidationFailedViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import Foundation

private enum Constants {
    enum Keys {
        static let title = "title_key".localized
        static let description = "description_key %@".localized
        static let accept = "accepts_button_key".localized
        static let cancel = "cancel_button_key".localized
        static let hintTitle = "hint_title_key".localized
        static let bulletOne = "bullet_one_key".localized
        static let bulletTwo = "bullet_two_key".localized
        static let bulletThree = "bullet_three_key".localized
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
    var title: String { return Constants.Keys.title }
    var description: String { return String(format: Constants.Keys.description, ticket.serviceProvider) }
    var acceptButtonText: String { return Constants.Keys.accept }
    var cancelButtonText: String { return Constants.Keys.cancel }
    var hintTitle: String { return Constants.Keys.hintTitle }
    var hintText: NSAttributedString {
        let bulletOne = Constants.Keys.bulletOne.styledAs(.body)
        let bulletTwo = Constants.Keys.bulletTwo.styledAs(.body)
        let bulletThree = Constants.Keys.bulletThree.styledAs(.body)
        return NSAttributedString.toBullets([bulletOne,
                                             bulletTwo,
                                             bulletThree])
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
