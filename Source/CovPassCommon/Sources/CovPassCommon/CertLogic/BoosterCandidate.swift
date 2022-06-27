//
//  BoosterCandidate.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic

public struct BoosterCandidate: Codable {
    public enum BoosterState: String, Codable {
        /// Not qualifified for a booster.
        case none
        /// New qualification for a booster.
        case new
        /// Qualified for a booster but already shown.
        case qualified
    }

    /// Identifier is used to identify the vaccination on which the rules were checked on.
    public var vaccinationIdentifier: String
    public var state: BoosterState
    /// All passed validation rules for this user.
    public var validationRules: [Rule]
    public let dgc: DigitalGreenCertificate

    public init(dgc: DigitalGreenCertificate, state: BoosterState, validationRules: [Rule]) {
        self.vaccinationIdentifier = dgc.uvci
        self.state = state
        self.validationRules = validationRules
        self.dgc = dgc
    }

    public init(certificate: ExtendedCBORWebToken) {
        self.init(
            dgc: certificate.vaccinationCertificate.hcert.dgc,
            state: .none,
            validationRules: []
        )
    }
}

extension BoosterCandidate: Equatable {
    public static func == (lhs: BoosterCandidate, rhs: BoosterCandidate) -> Bool {
        lhs.dgc == rhs.dgc
    }
}
