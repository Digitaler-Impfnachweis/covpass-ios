//
//  ValidationServiceViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassCommon
@testable import CovPassUI
import XCTest
import PromiseKit

class ValidationServiceViewControllerSnapShotTests: BaseSnapShotTests {
    func testConsentScreen() {
        let vm = ValidationServiceViewModel(router: ValidationServiceRouterMock(), initialisationData: ValidationServiceInitialisation.mock)
        let vc = ValidationServiceViewController(viewModel: vm)

        verifyView(view: vc.view, height: 1350)
    }

    func testWebViewScreen() {
        let vm = WebviewViewModel(title: "app_information_title_datenschutz".localized(bundle: Bundle.uiBundle),
                                  url: ValidationServiceInitialisation.mock.privacyUrl,
                                  closeButtonShown: false,
                                  isToolbarShown: true)
        let vc = WebviewViewController(viewModel: vm)

        verifyView(view: vc.view)
    }
}

struct ValidationServiceRouterMock: ValidationServiceRoutable {
    func routeToConsentGeneralConsent() {

    }

    func routeToWarning() {

    }

    func routeToSelectCertificate() {

    }

    func routeToCertificateConsent() {

    }

    func routeToPrivacyStatement(url: URL) {

    }


    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
}

extension ValidationServiceInitialisation {
    
    static var mock: ValidationServiceInitialisation {
        let data =
        """
        {
          "protocol": "DCCVALIDATION",
          "protocolVersion": "1.0.0",
          "serviceIdentity": "https://dgca-booking-demo-eu-test.cfapps.eu10.hana.ondemand.com/api/identity",
          "privacyUrl": "https://validation-decorator.example",
          "token": "eyJ0eXAiOiJKV1QiLCJraWQiOiJiUzhEMi9XejV0WT0iLCJhbGciOiJFUzI1NiJ9.eyJpc3MiOiJodHRwczovL2RnY2EtYm9va2luZy1kZW1vLWV1LXRlc3QuY2ZhcHBzLmV1MTAuaGFuYS5vbmRlbWFuZC5jb20vYXBpL2lkZW50aXR5IiwiZXhwIjoxNjM1MDczMTg5LCJzdWIiOiI2YTJhYjU5MS1jMzgzLTRlOWEtYjMwOS0zNjBjNThkYWQ5M2YifQ.vo_YxeSM02knOLASRNs74qTErKWCNo9Zq8-7TVIc1HvaGkVf_r5USnUBcyDykSsmj8Ckle5lGnHAvU1krfpk3A",
          "consent": "Please confirm to start the DCC Exchange flow. If you not confirm, the flow is aborted.",
          "subject": "6a2ab591-c383-4e9a-b309-360c58dad93f",
          "serviceProvider": "Booking Demo"
        }
        """.data(using: .utf8)!
        return try! JSONDecoder().decode(ValidationServiceInitialisation.self, from: data)
    }
}
