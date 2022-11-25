//
//  CertificateRevocationServiceState.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

/// Defines the states the certificate revocation download service can be in.
public enum CertificateRevocationServiceState {
    /// The last update finished successfully.
    case completed

    /// An error happend during the last update.
    case error

    /// The service does nothing currently.
    case idle

    /// The service currently updates the revocation data.
    case updating

    /// The service is doing a reset.
    case cancelling
}
