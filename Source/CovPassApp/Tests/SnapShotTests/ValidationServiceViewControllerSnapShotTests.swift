//
//  ValidationServiceViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassCommon
@testable import CovPassUI
import JWTDecode
import PromiseKit
import XCTest

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
                                  isToolbarShown: true,
                                  enableDynamicFonts: false,
                                  openingAnnounce: "",
                                  closingAnnounce: "")
        let vc = WebviewViewController(viewModel: vm)

        verifyView(view: vc.view)
    }

    func testValidationConsentScreen() {
        let vm = ConsentExchangeViewModel(router: ValidationServiceRouterMock(), vaasRepository: VAASRepositoryMock(step: .downloadAccessToken),
                                          initialisationData: ValidationServiceInitialisation.mock,
                                          certificate: try! ExtendedCBORWebToken.mock())
        let vc = ConsentExchangeViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1850)
    }

    func test_validation_result_passed() {
        var vaasValidationResultToken = VAASValidaitonResultToken.mock
        vaasValidationResultToken.result = .passed
        vaasValidationResultToken.provider = "Lufthansa"
        vaasValidationResultToken.verifyingService = "Booking Demo Validation Service TSI"
        let vm = CertificateItemDetailViewModel(router: CertificateItemDetailRouterMock(), repository: VaccinationRepositoryMock(), certificate: try! ExtendedCBORWebToken.mock(), resolvable: nil, vaasResultToken: vaasValidationResultToken)
        let vc = CertificateItemDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 2200)
    }

    func test_validation_result_cross_check() {
        var vaasValidationResultToken = VAASValidaitonResultToken.mock
        vaasValidationResultToken.result = .crossCheck
        vaasValidationResultToken.provider = "Lufthansa"
        vaasValidationResultToken.verifyingService = "Betreiber_Validationservice"
        let vm = CertificateItemDetailViewModel(router: CertificateItemDetailRouterMock(), repository: VaccinationRepositoryMock(), certificate: try! ExtendedCBORWebToken.mock(), resolvable: nil, vaasResultToken: vaasValidationResultToken)
        let vc = CertificateItemDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 2200)
    }

    func test_validation_result_fail() {
        var vaasValidationResultToken = VAASValidaitonResultToken.mock
        vaasValidationResultToken.result = .fail
        vaasValidationResultToken.provider = "Lufthansa"
        vaasValidationResultToken.verifyingService = "Betreiber_Validationservice"
        let vm = CertificateItemDetailViewModel(router: CertificateItemDetailRouterMock(), repository: VaccinationRepositoryMock(), certificate: try! ExtendedCBORWebToken.mock(), resolvable: nil, vaasResultToken: vaasValidationResultToken)
        let vc = CertificateItemDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 2200)
    }
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

extension VAASValidaitonResultToken {
    static var mock: VAASValidaitonResultToken {
        let validationResultJWT = """
        eyJ0eXAiOiJKV1QiLCJraWQiOiJSQU0yU3R3N0VrRT0iLCJhbGciOiJFUzI1NiJ9.eyJzdWIiOiIyMDI3YTE5ZC1lMzVhLTQxYjUtOWRlZi00NzEyMTFmMGNjZWUiLCJpc3MiOiJodHRwczovL2RnY2EtdmFsaWRhdGlvbi1zZXJ2aWNlLWV1LXRlc3QuY2ZhcHBzLmV1MTAuaGFuYS5vbmRlbWFuZC5jb20iLCJpYXQiOjE2Mzc3NDYwNTIsImV4cCI6MTYzNzgzMjQ1MiwiY2F0ZWdvcnkiOlsiU3RhbmRhcmQiXSwiY29uZmlybWF0aW9uIjoiZXlKcmFXUWlPaUpTUVUweVUzUjNOMFZyUlQwaUxDSmhiR2NpT2lKRlV6STFOaUo5LmV5SnFkR2tpT2lKaE9USTROV1EyTWkwMll6QTJMVFJsT0RVdE9UZ3lOeTB6WVdJeVpHSTVNR0ZsTVdVaUxDSnpkV0lpT2lJeU1ESTNZVEU1WkMxbE16VmhMVFF4WWpVdE9XUmxaaTAwTnpFeU1URm1NR05qWldVaUxDSnBjM01pT2lKb2RIUndjem92TDJSblkyRXRkbUZzYVdSaGRHbHZiaTF6WlhKMmFXTmxMV1YxTFhSbGMzUXVZMlpoY0hCekxtVjFNVEF1YUdGdVlTNXZibVJsYldGdVpDNWpiMjBpTENKcFlYUWlPakUyTXpjM05EWXdOVElzSW1WNGNDSTZNVFl6Tnpnek1qUTFNaXdpY21WemRXeDBJam9pVDBzaUxDSmpZWFJsWjI5eWVTSTZXeUpUZEdGdVpHRnlaQ0pkZlEuUHV0X2RkQlBNMmtMVFZkTWF0dVNTYjFVM0RTYnNORTJhMkh1WjVLMmZ5UVVITnM4NlBuYjh4MzFja1J3aUxmVWczTGVxcTBkNUhxNXJaN3IzTFk5WXciLCJyZXN1bHRzIjpbXSwicmVzdWx0IjoiT0sifQ.BdQr1acy81yHqBKTuVbbbO9ATYIhbT1XNit0mE3VIO-D-SLOwc-_is4_mEp8k1wD6zAMqNYk_Gl7srm5LFkz3Q
        """
        let decodedJWT = try! decode(jwt: validationResultJWT)
        let jsondata = try! JSONSerialization.data(withJSONObject: decodedJWT.body)
        let vaasValidationResultToken = try! JSONDecoder().decode(VAASValidaitonResultToken.self, from: jsondata)
        return vaasValidationResultToken
    }
}
