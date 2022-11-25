//
//  CertificateRevocationChunkListResponse.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

public struct CertificateRevocationChunkListResponse {
    public let hashes: [CertificateRevocationHash]
    public let lastModified: String?

    init(hashes: [CertificateRevocationHash], lastModified: String? = nil) {
        self.hashes = hashes
        self.lastModified = lastModified
    }
}
