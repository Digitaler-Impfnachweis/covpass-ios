//
//  VAASRepositoryMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import Foundation
import PromiseKit

struct VAASRepositoryMock: VAASRepositoryProtocol {
    var useUnsecureApi: Bool = false
    var step: VAASStep
    let validationResultJWT = """
    eyJ0eXAiOiJKV1QiLCJraWQiOiJSQU0yU3R3N0VrRT0iLCJhbGciOiJFUzI1NiJ9.eyJzdWIiOiIyMDI3YTE5ZC1lMzVhLTQxYjUtOWRlZi00NzEyMTFmMGNjZWUiLCJpc3MiOiJodHRwczovL2RnY2EtdmFsaWRhdGlvbi1zZXJ2aWNlLWV1LXRlc3QuY2ZhcHBzLmV1MTAuaGFuYS5vbmRlbWFuZC5jb20iLCJpYXQiOjE2Mzc3NDYwNTIsImV4cCI6MTYzNzgzMjQ1MiwiY2F0ZWdvcnkiOlsiU3RhbmRhcmQiXSwiY29uZmlybWF0aW9uIjoiZXlKcmFXUWlPaUpTUVUweVUzUjNOMFZyUlQwaUxDSmhiR2NpT2lKRlV6STFOaUo5LmV5SnFkR2tpT2lKaE9USTROV1EyTWkwMll6QTJMVFJsT0RVdE9UZ3lOeTB6WVdJeVpHSTVNR0ZsTVdVaUxDSnpkV0lpT2lJeU1ESTNZVEU1WkMxbE16VmhMVFF4WWpVdE9XUmxaaTAwTnpFeU1URm1NR05qWldVaUxDSnBjM01pT2lKb2RIUndjem92TDJSblkyRXRkbUZzYVdSaGRHbHZiaTF6WlhKMmFXTmxMV1YxTFhSbGMzUXVZMlpoY0hCekxtVjFNVEF1YUdGdVlTNXZibVJsYldGdVpDNWpiMjBpTENKcFlYUWlPakUyTXpjM05EWXdOVElzSW1WNGNDSTZNVFl6Tnpnek1qUTFNaXdpY21WemRXeDBJam9pVDBzaUxDSmpZWFJsWjI5eWVTSTZXeUpUZEdGdVpHRnlaQ0pkZlEuUHV0X2RkQlBNMmtMVFZkTWF0dVNTYjFVM0RTYnNORTJhMkh1WjVLMmZ5UVVITnM4NlBuYjh4MzFja1J3aUxmVWczTGVxcTBkNUhxNXJaN3IzTFk5WXciLCJyZXN1bHRzIjpbXSwicmVzdWx0IjoiT0sifQ.BdQr1acy81yHqBKTuVbbbO9ATYIhbT1XNit0mE3VIO-D-SLOwc-_is4_mEp8k1wD6zAMqNYk_Gl7srm5LFkz3Q
    """

    func validateTicketing(choosenCert _: ExtendedCBORWebToken) throws -> Promise<VAASValidaitonResultToken> {
        .init(error: APIError.invalidResponse)
    }

    var ticket = ValidationServiceInitialisation.mock

    var selectedValidationService: ValidationService?

    func fetchValidationService() -> Promise<AccessTokenResponse> {
        .value(AccessTokenResponse(vc: ValidationCertificate(fnt: "Schneider", gnt: "Andrea", dob: "1990-07-12", type: ["v", "r", "t"])))
    }

    func validateTicketing(choosenCert _: ExtendedCBORWebToken) throws -> Promise<Void> {
        .value(())
    }

    func cancellation() {}
}
