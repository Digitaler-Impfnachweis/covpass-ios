//
//  CertificateRevocationServiceProtocol.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Describes the interface of a download service for certificate revocation info. An implementing class
/// should download the complete revocation tree from the revocation backend and store it locally on the
/// device. An implementation of `CertificateRepositoryProtocol` can then be used as drop-in
/// alternative for offline look-up of the revocation status of a certficate.
public protocol CertificateRevocationOfflineServiceProtocol {
    /// Date of the last update.
    var lastSuccessfulUpdate: Date? { get }

    /// State of the update process.
    var state: CertificateRevocationServiceState { get }

    /// Asynchronously starts an update. If state is `.idle` or `.error` it is set to `.updating` and
    /// the update is started. If state already is `.updating` the call is ignored. If an error happens
    /// during update the state is set to `.error` and the process is stopped. After successful download
    /// all updated revocation info is downloaded and  the state will be `completed`.
    func update()

    /// Interupts a possibly ongoing update, deletes all downloaded data, set the `state` to `.idle`
    /// and resets the date of last successful update.
    func reset()

    /// Performs an update as described for `update()`, but only if 24h passed since last successful
    /// update.
    func updateIfNeeded()
}


