//
//  CertificateRevocationService.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public class CertificateRevocationOfflineService: CertificateRevocationOfflineServiceProtocol {
    public private(set) var state: CertificateRevocationServiceState = .idle
    public private(set) var lastSuccessfulUpdate: Date? {
        get {
            persistence.certificateRevocationOfflineServiceLastUpdate
        }
        set {
            persistence.certificateRevocationOfflineServiceLastUpdate = newValue
        }
    }

    private let dateProvider: DateProviding
    private var persistence: Persistence
    private let localDataSource: CertificateRevocationFilessystemDataSourceProtocol
    private let remoteDataSource: CertificateRevocationHTTPDataSourceProtocol

    public init(
        localDataSource: CertificateRevocationFilessystemDataSourceProtocol,
        remoteDataSource: CertificateRevocationHTTPDataSourceProtocol,
        dateProvider: DateProviding,
        persistence: Persistence
    ) {
        self.dateProvider = dateProvider
        self.persistence = persistence
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    public func update() -> Promise<Void> {
        guard state != .updating, state != .cancelling else { return .value }
        state = .updating
        let promise = updateKIDList()
            .then(updateIndexLists)
            .then(updateChunkLists)
            .done { _ in
                self.handleSuccess()
            }

        promise.catch { error in
            self.handle(error: error)
        }
        return promise
    }

    private func updateKIDList() -> Promise<Void> {
        localDataSource
            .getKIDListLastModified()
            .map(kidListHTTPHeaders)
            .then(remoteDataSource.getKIDList(httpHeaders:))
            .then { response -> Promise<Void> in
                if let response = response {
                    return self.localDataSource.putKIDList(response)
                }
                return .value
            }
            .then(checkIfCancelled)
    }

    private func kidListHTTPHeaders(ifModifiedSince: String?) -> [String: String?] {
        [
            HTTPHeader.ifModifiedSince: ifModifiedSince
        ]
    }

    private func updateIndexLists() -> Promise<Void> {
        localDataSource
            .getKIDList()
            .then { response -> Promise<Void> in
                var hashTypeIterator = CertificateRevocationHashType.allCases.makeIterator()
                let iterator = AnyIterator<Promise<Void>> {
                    guard let hashType = hashTypeIterator.next() else {
                        return nil
                    }
                    let kids = response.kids(with: hashType)
                    if kids.isEmpty {
                        return .value
                    }
                    return self.updateIndexLists(kids: kids, hashType: hashType)
                }
                return when(
                    fulfilled: iterator,
                    concurrently: 1
                ).asVoid()
            }
    }

    private func updateIndexLists(kids: [KID], hashType: CertificateRevocationHashType) -> Promise<Void> {
        var kidsIterator = kids.makeIterator()
        let iterator = AnyIterator<Promise<Void>> {
            guard let kid = kidsIterator.next() else {
                return nil
            }
            return self.updateIndexList(kid: kid, hashType: hashType)
        }
        return when(fulfilled: iterator, concurrently: 4).asVoid()
    }

    private func updateIndexList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void> {
        localDataSource
            .getIndexListLastModified(kid: kid, hashType: hashType)
            .map(indexListHTTPHeaders)
            .then { headers in
                self.remoteDataSource.getIndexList(
                    kid: kid,
                    hashType: hashType,
                    httpHeaders: headers
                )
            }
            .then { response -> Promise<Void> in
                if let response = response {
                    return self.localDataSource.putIndexList(
                        response,
                        kid: kid,
                        hashType: hashType
                    )
                }
                return .value
            }
            .then(checkIfCancelled)
    }

    private func indexListHTTPHeaders(ifModifiedSince: String?) -> [String: String?] {
        [
            HTTPHeader.ifModifiedSince: ifModifiedSince
        ]
    }

    private func updateChunkLists() -> Promise<Void> {
        localDataSource
            .getKIDList()
            .then { response -> Promise<Void> in
                var hashTypeIterator = CertificateRevocationHashType.allCases.makeIterator()
                let iterator = AnyIterator<Promise<Void>> {
                    guard let hashType = hashTypeIterator.next() else {
                        return nil
                    }
                    let kids = response.kids(with: hashType)
                    if kids.isEmpty {
                        return .value
                    }
                    return self.updateChunkLists(kids: kids, hashType: hashType)
                }
                return when(
                    fulfilled: iterator,
                    concurrently: 1
                ).asVoid()
            }
    }

    private func updateChunkLists(kids: [KID], hashType: CertificateRevocationHashType) -> Promise<Void> {
        var kidsIterator = kids.makeIterator()
        let iterator = AnyIterator<Promise<Void>> {
            guard let kid = kidsIterator.next() else {
                return nil
            }
            return self.updateChunkList(kid: kid, hashType: hashType)
        }
        return when(fulfilled: iterator, concurrently: 4).asVoid()
    }

    private func updateChunkList(kid: KID, hashType: CertificateRevocationHashType) -> Promise<Void> {
        localDataSource
            .getChunkListLastModified(kid: kid, hashType: hashType)
            .map(chunkListHTTPHeaders)
            .then { headers in
                self.remoteDataSource.getChunkList(
                    kid: kid,
                    hashType: hashType,
                    httpHeaders: headers
                )
            }
            .then { response -> Promise<Void> in
                if let response = response {
                    return self.localDataSource.putChunkList(
                        response,
                        kid: kid,
                        hashType: hashType
                    )
                }
                return .value
            }
            .then(checkIfCancelled)
    }

    private func chunkListHTTPHeaders(ifModifiedSince: String?) -> [String: String?] {
        [
            HTTPHeader.ifModifiedSince: ifModifiedSince
        ]
    }

    private func handleSuccess() {
        lastSuccessfulUpdate = dateProvider.now()
        state = .completed
    }

    private func handle(error: Error) {
        if let error = error as? CertificateRevocationOfflineServiceError, case .cancelled = error {
            deleteAllLocalData()
            return
        }
        state = .error
    }

    private func checkIfCancelled() -> Promise<Void> {
        state == .cancelling ?
            .init(error: CertificateRevocationOfflineServiceError.cancelled) :
            .value
    }

    public func reset() {
        if state == .updating {
            state = .cancelling
        } else {
            deleteAllLocalData()
        }
    }

    private func deleteAllLocalData() {
        localDataSource.deleteAll()
            .ensure {
                self.lastSuccessfulUpdate = nil
            }
            .done { _ in
                self.state = .idle
            }
            .catch { _ in
                self.state = .error
            }
    }

    public func updateNeeded() -> Bool {
        if let lastSuccessfulUpdate = lastSuccessfulUpdate,
           dateProvider.now().hoursSince(lastSuccessfulUpdate) < 24 {
            return false
        }
        return true
    }

    public func updateIfNeeded() {
        if updateNeeded() {
            update().cauterize()
        }
    }
}
