//
//  CertificateItemDetailViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

class CertificateItemDetailViewControllerSnapshotTests: BaseSnapShotTests {
    private var sut: CertificateItemDetailViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        try configureSut(token: .token1Of1())
    }

    private func configureSut(token: ExtendedCBORWebToken,
                              tokens: [ExtendedCBORWebToken] = []) {
        let viewModel = CertificateItemDetailViewModel(
            router: CertificateItemDetailRouterMock(),
            repository: VaccinationRepositoryMock(),
            certificate: token,
            certificates: tokens,
            resolvable: nil,
            vaasResultToken: nil
        )
        sut = CertificateItemDetailViewController(viewModel: viewModel)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: Vaccination

    func test_reissuable_soon_expiring_vaccination() {
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring])
        verifyView(view: sut.view, height: 600, overallTolerance: 0.01)
    }

    func test_reissuable_expired_vaccination() {
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_expiredLessThen90Days])
        verifyView(view: sut.view, height: 600, overallTolerance: 0.01)
    }

    func test_expired_doesnt_have_to_be_renewed_vaccination() {
        configureSut(token: .vaccination_expiredLessThen90Days, tokens: [.vaccination_soonExpiring, .vaccination_expiredLessThen90Days])
        verifyView(view: sut.view, height: 600, overallTolerance: 0.01)
    }

    func test_expiring_doesnt_have_to_be_renewed_vaccination() {
        configureSut(token: .vaccination_soonExpiring, tokens: [.vaccination_soonExpiring, .vaccination_soonExpiring_superseeding_the_other_soon_expiring])
        verifyView(view: sut.view, height: 600, overallTolerance: 0.01)
    }

    func test_expired_cant_be_renewed_vaccination() {
        configureSut(token: .vaccination_expiredMoreThen90Days, tokens: [.vaccination_expiredMoreThen90Days])
        verifyView(view: sut.view, height: 600, overallTolerance: 0.01)
    }

    func test_expired_cant_be_renewed_not_german_vaccination() {
        configureSut(token: .vaccinatione_expiredNotGerman, tokens: [.vaccinatione_expiredNotGerman])
        verifyView(view: sut.view, height: 600)
    }

    func test_revoked_vaccination() {
        configureSut(token: .vaccination_revokedAndExpired, tokens: [.vaccination_revokedAndExpired])
        verifyView(view: sut.view, height: 600)
    }

    func test_revoked_non_german_vaccination() {
        configureSut(token: .vaccination_revokedAndNotExpiredAndNotGerman, tokens: [.vaccination_revokedAndNotExpiredAndNotGerman])
        verifyView(view: sut.view, height: 600)
    }

    func test_revoked_by_locationId_vaccination() {
        configureSut(token: .vaccination_revokedByLocationId, tokens: [.vaccination_revokedByLocationId])
        verifyView(view: sut.view, height: 600)
    }

    func test_valid_vaccination() {
        configureSut(token: .vaccination_valid, tokens: [.vaccination_valid])
        verifyView(view: sut.view, height: 600)
    }

    // MARK: Recovery

    func test_reissuable_soon_expiring_recovery_and() {
        configureSut(token: .recovery_soonExpiring, tokens: [.recovery_soonExpiring])
        verifyView(view: sut.view, height: 600, overallTolerance: 0.01)
    }

    func test_reissuable_expired_recovery() {
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_expiredLessThen90Days])
        verifyView(view: sut.view, height: 600, overallTolerance: 0.01)
    }

    func test_expired_doesnt_have_to_be_renewed_recovery() {
        configureSut(token: .recovery_expiredLessThen90Days, tokens: [.recovery_soonExpiring, .recovery_expiredLessThen90Days])
        verifyView(view: sut.view, height: 600, overallTolerance: 0.01)
    }

    func test_expiring_doesnt_have_to_be_renewed_recovery() {
        configureSut(token: .recovery_soonExpiring, tokens: [.recovery_soonExpiring, .vaccination_soonExpiring_superseeding_the_other_soon_expiring])
        verifyView(view: sut.view, height: 600, overallTolerance: 0.01)
    }

    func test_expired_cant_be_renewed_recovery() {
        configureSut(token: .recovery_expiredMoreThen90Days, tokens: [.recovery_expiredMoreThen90Days])
        verifyView(view: sut.view, height: 600, overallTolerance: 0.01)
    }

    func test_expired_cant_be_renewed_not_german_recovery() {
        configureSut(token: .recovery_expiredNotGerman, tokens: [.recovery_expiredNotGerman])
        verifyView(view: sut.view, height: 600)
    }

    func test_revoked_recovery() {
        configureSut(token: .recovery_revokedAndExpired, tokens: [.recovery_revokedAndExpired])
        verifyView(view: sut.view, height: 600)
    }

    func test_revoked_non_german_recovery() {
        configureSut(token: .recovery_revokedAndNotExpiredAndNotGerman, tokens: [.recovery_revokedAndNotExpiredAndNotGerman])
        verifyView(view: sut.view, height: 600)
    }

    func test_revoked_by_locationId_recovery() {
        configureSut(token: .recovery_revokedByLocationId, tokens: [.recovery_revokedByLocationId])
        verifyView(view: sut.view, height: 600)
    }

    func test_valid_recovery() {
        configureSut(token: .recovery_valid, tokens: [.recovery_valid])
        verifyView(view: sut.view, height: 600)
    }

    // MARK: Test

    func test_reissuable_soon_expiring_test() {
        configureSut(token: .test_soonExpiring, tokens: [.test_soonExpiring])
        verifyView(view: sut.view, height: 600)
    }

    func test_reissuable_expired_test() {
        configureSut(token: .test_expiredLessThen90Days, tokens: [.test_expiredLessThen90Days])
        verifyView(view: sut.view, height: 600)
    }

    func test_expired_doesnt_have_to_be_renewed_test() {
        configureSut(token: .test_expiredLessThen90Days, tokens: [.vaccination_soonExpiring, .test_expiredLessThen90Days])
        verifyView(view: sut.view, height: 600)
    }

    func test_expiring_doesnt_have_to_be_renewed_test() {
        configureSut(token: .test_soonExpiring, tokens: [.test_soonExpiring, .vaccination_soonExpiring_superseeding_the_other_soon_expiring])
        verifyView(view: sut.view, height: 600)
    }

    func test_expired_cant_be_renewed_test() {
        configureSut(token: .test_expiredMoreThen90Days, tokens: [.test_expiredMoreThen90Days])
        verifyView(view: sut.view, height: 600)
    }

    func test_expired_cant_be_renewed_not_german_test() {
        configureSut(token: .test_expiredNotGerman, tokens: [.test_expiredNotGerman])
        verifyView(view: sut.view, height: 600)
    }

    func test_revoked_test() {
        configureSut(token: .test_revokedAndExpired, tokens: [.test_revokedAndExpired])
        verifyView(view: sut.view, height: 600)
    }

    func test_revoked_non_german_test() {
        configureSut(token: .test_revokedAndNotExpiredAndNotGerman, tokens: [.test_revokedAndNotExpiredAndNotGerman])
        verifyView(view: sut.view, height: 600)
    }

    func test_revoked_by_locationId_test() {
        configureSut(token: .test_revokedByLocationId, tokens: [.test_revokedByLocationId])
        verifyView(view: sut.view, height: 600)
    }

    func test_valid_test() {
        configureSut(token: .test_valid, tokens: [.test_valid])
        verifyView(view: sut.view, height: 600)
    }
}
