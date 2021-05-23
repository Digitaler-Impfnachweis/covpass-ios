//
//  ExtendedCBORWebToken+Filter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

extension Array where Element == ExtendedCBORWebToken {
    public func firstCertificateWithId(_ id: String) -> Element? {
        first(where: { $0.vaccinationCertificate.hcert.dgc.v.first?.ci == id })
    }

    public func containsCertificateWithId(_ id: String) -> Bool {
        contains(
            where: {
                $0.vaccinationCertificate.hcert.dgc.v.first?.ci == id
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

    /// Reduce all certificate to pairs and take either the full cert or the last known.
    public func flatMapCertificatePairs() -> [Element] {
        reduce(into: [Element?]()) { result, certificate in
            let pair = certificatePair(for: certificate)
            let preferedCertificate = pair.first(where: { $0.vaccinationCertificate.hcert.dgc.fullImmunization }) ?? pair.last
            if result.contains(preferedCertificate) == false {
                result.append(preferedCertificate)
            }
        }
        .compactMap { $0 }
    }

    /// Brings the certificate with given id to the beginning of the given list.
    public func makeFirstWithId(_ certificateId: String?) -> [Element] {
        guard
            let id = certificateId,
            let favoriteCertificate = firstCertificateWithId(id) else {
            return self
        }
        return [favoriteCertificate] + filter { $0 != favoriteCertificate }
    }

    public func first(for vaccination: Vaccination) -> Element? {
        first { certificate in
            certificate.vaccinationCertificate.hcert.dgc.v.first(where: { $0 == vaccination }) != nil
        }
    }
}
