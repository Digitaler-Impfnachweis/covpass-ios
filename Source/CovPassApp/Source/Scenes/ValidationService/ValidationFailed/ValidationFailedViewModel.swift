//
//  ValidationFailedViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit

private enum Constants {

}

struct ValidationFailedViewModel {

    let resolvable: Resolver<Bool>
    let ticket: ValidationServiceInitialisation

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
