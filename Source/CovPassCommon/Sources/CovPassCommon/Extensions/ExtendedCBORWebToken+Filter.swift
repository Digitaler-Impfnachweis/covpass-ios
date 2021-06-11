//
//  ExtendedCBORWebToken+Filter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

public extension Array where Element == ExtendedCBORWebToken {
    func firstCertificateWithId(_ id: String) -> Element? {
        first(where: { $0.vaccinationCertificate.hcert.dgc.v?.first?.ci == id })
    }

    func containsCertificateWithId(_ id: String) -> Bool {
        contains(
            where: {
                $0.vaccinationCertificate.hcert.dgc.v?.first?.ci == id
            }
        )
    }

    func firstIndex(of certificate: Element?) -> Int? {
        firstIndex {
            $0.vaccinationCertificate.hcert.dgc == certificate?.vaccinationCertificate.hcert.dgc
        }
    }

    func pairableCertificates(for certificate: Element) -> [Element] {
        filter {
            $0.vaccinationCertificate.hcert.dgc == certificate.vaccinationCertificate.hcert.dgc
        }
    }

    func certificatePair(for certificate: Element) -> [Element] {
        if isEmpty {
            return []
        }
        return pairableCertificates(for: certificate)
    }
}
