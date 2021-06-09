//
//  ExtendedCBORWebToken+Filter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

extension Array where Element == ExtendedCBORWebToken {
    public func firstCertificateWithId(_ id: String) -> Element? {
        first(where: { $0.vaccinationCertificate.hcert.dgc.v?.first?.ci == id })
    }

    public func containsCertificateWithId(_ id: String) -> Bool {
        contains(
            where: {
                $0.vaccinationCertificate.hcert.dgc.v?.first?.ci == id
            }
        )
    }

    public func firstIndex(of certificate: Element?) -> Int? {
        firstIndex {
            $0.vaccinationCertificate.hcert.dgc == certificate?.vaccinationCertificate.hcert.dgc
        }
    }

    public func pairableCertificates(for certificate: Element) -> [Element] {
        filter {
            $0 != certificate
        }
        .filter {
            $0.vaccinationCertificate.hcert.dgc == certificate.vaccinationCertificate.hcert.dgc
        }
    }

    public func certificatePair(for certificate: Element) -> [Element] {
        if isEmpty {
            return []
        }
        return pairableCertificates(for: certificate) + [certificate]
    }
}
