//
//  ValidationFailedSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import CovPassApp
@testable import CovPassCommon
import PromiseKit

class ValidationFailedSnapShotTests: BaseSnapShotTests {

    func testDefault() {
        let (_, resolver) = Promise<Bool>.pending()
        let vc = ValidationFailedViewController(viewModel: ValidationFailedViewModel(resolvable: resolver,
                                                                                     ticket: ValidationServiceInitialisation.mock))
        verifyView(vc: vc)
    }
    
    func testMockText() {
        let vc = ValidationFailedViewController(viewModel: ValidationFailedViewModelMock())
        verifyView(vc: vc)
    }

}


struct ValidationFailedViewModelMock: ValidationFailedViewModelProtocol {
    
    var title: String { "Unbekannter Anbieter" }
    
    var description: String { "Der Anbieter %@ ist uns nicht bekannt. Falls Sie fortfahren, überprüfen Sie bitte die Herkunft des QR-Codes und vergewissern Sie sich, ob Sie dem Anbieter Ihr Zertifikat übermitteln möchten" }
    
    var acceptButtonText: String { "Trotzdem weiter" }
    
    var cancelButtonText: String { "Abbrechen" }
    
    var hintTitle: String { "Achten Sie besonders auf:" }
    
    var hintText: NSAttributedString {
        let one = NSAttributedString(string: "Test 1")
        return NSAttributedString.toBullets([one, one, one, one, one, one, one, one, one, one, one, one, one, one, one, one])
    }
    
    func continueProcess() { }
    
    func cancelProcess() { }
}
