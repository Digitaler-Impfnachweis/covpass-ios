//
//  VaccinationResultViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import PromiseKit
import XCTest

class VaccinationResultViewModelTests: XCTestCase {
    private var audioPlayer: AudioPlayerMock!
    private var promise: Promise<ExtendedCBORWebToken>!
    private var router: ValidationResultRouterMock!
    private var sut: VaccinationResultViewModel!
    private var delegate: ResultViewModelDelegateMock!

    override func setUpWithError() throws {
        let (promise, resolver) = Promise<ExtendedCBORWebToken>.pending()
        self.promise = promise
        delegate = .init()
        router = .init()
        audioPlayer = .init()
        sut = .init(
            resolvable: resolver,
            router: router,
            repository: VaccinationRepositoryMock(),
            certificate: nil,
            _2GContext: false,
            userDefaults: UserDefaultsPersistence(),
            revocationKeyFilename: "",
            countdownTimerModel: .init(
                dismissAfterSeconds: 0,
                countdownDuration: 0
            ),
            revocationRepository: CertificateRevocationRepositoryMock(),
            audioPlayer: audioPlayer
        )
        sut.delegate = delegate
    }

    override func tearDownWithError() throws {
        audioPlayer = nil
        delegate = nil
        promise = nil
        router = nil
        sut = nil
    }

    func testInit() {
        // Given
        let expectation = XCTestExpectation()
        promise
            .cancelled {
                expectation.fulfill()
            }
            .cauterize()

        // Then
        XCTAssertNotNil(sut.countdownTimerModel)
        wait(for: [router.showStartExpectation, expectation], timeout: 2)
        XCTAssertEqual(sut.countdownTimerModel?.shouldDismiss, true)
    }

    func testScanCerificate() {
        // When
        sut.scanCertificate()

        // Then
        wait(for: [audioPlayer.playCovPassCheckCertificateScannedIfEnabledExpectation], timeout: 1)
    }
}
