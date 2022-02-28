//
//  Array+ExtendedCBORWebToken.swift
//  
//
//  Created by Thomas Kuleßa on 23.02.22.
//

public extension Array where Element == ExtendedCBORWebToken {
    /// Splits the receiver in an array of sub-arrays. Eachs sub-array contains the certificates for one owner.
    var partitionedByOwner: [Self] {
        var partitions = [Self]()
        for extendedCBORWebToken in self {
            if let index = partitions.firstIndex(where: { $0.containsMatching(extendedCBORWebToken) }) {
                partitions[index].append(extendedCBORWebToken)
            } else {
                partitions.append([extendedCBORWebToken])
            }
        }
        return partitions
    }

    private func containsMatching(_ extendedCBORWebToken: ExtendedCBORWebToken) -> Bool {
        contains { $0.matches(extendedCBORWebToken) }
    }

    var qualifiedForReissue: Bool {
        // TODO: Implement
        // Input should be an array of tokens for one person only.
        // Set to true for testing.
        false
    }
}

private extension ExtendedCBORWebToken {
    func matches(_ extendedCBORWebToken: ExtendedCBORWebToken) -> Bool {
        vaccinationCertificate.hcert.dgc == extendedCBORWebToken.vaccinationCertificate.hcert.dgc
    }
}
