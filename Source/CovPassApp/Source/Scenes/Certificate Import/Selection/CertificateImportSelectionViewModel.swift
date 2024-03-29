//
//  CertificateImportSelectionViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit

private enum Constants {
    static let buttonTitleFormat = "file_import_result_button".localized
    static let emptyButtonTitle = "file_import_result_null_button".localized
    static let hintTitle = "file_import_result_info_title".localized
    static let selectionTitleFormat = "file_import_result_bulge_select".localized
    static let title = "file_import_result_title".localized
    static let emptyTitle = "file_import_result_null_title".localized
    static let hintBulletPoints = [
        "file_import_result_info_bullet1".localized,
        "file_import_result_info_bullet2".localized,
        "file_import_result_info_bullet3".localized
    ]
}

final class CertificateImportSelectionViewModel: CertificateImportSelectionViewModelProtocol {
    let title: String
    let hideSelection: Bool
    let hintTitle = Constants.hintTitle
    let hintTextBulletPoints = Constants.hintBulletPoints
    let items: [CertificateImportSelectionItem]
    var delegate: ViewModelDelegate?

    private let vaccinationRepository: VaccinationRepositoryProtocol
    private let resolver: Resolver<Void>
    private let router: CertificateImportSelectionRouterProtocol

    private(set) var isImportingCertificates = false {
        didSet {
            delegate?.viewModelDidUpdate()
        }
    }

    var buttonTitle: String {
        items.isEmpty ? Constants.emptyButtonTitle : .init(format: Constants.buttonTitleFormat, selectedItems.count)
    }

    var selectionTitle: String {
        .init(
            format: Constants.selectionTitleFormat,
            selectedItems.count,
            items.count
        )
    }

    private var selectedItems: [CertificateImportSelectionItem] {
        items.filter(\.selected)
    }

    private var selectedTokens: [ExtendedCBORWebToken] {
        selectedItems.map(\.token)
    }

    var itemSelectionState: CertificateImportSelectionState {
        switch selectedItems.count {
        case 0:
            return .none
        case 1 ..< items.count:
            return .some
        default:
            return .all
        }
    }

    var enableButton: Bool {
        selectedItems.count > 0 || items.isEmpty
    }

    init(tokens: [ExtendedCBORWebToken],
         vaccinationRepository: VaccinationRepositoryProtocol,
         resolver: Resolver<Void>,
         router: CertificateImportSelectionRouterProtocol) {
        self.router = router
        self.vaccinationRepository = vaccinationRepository
        items = tokens
            .sorted(by: ExtendedCBORWebToken.sortByFirstName)
            .map(\.certificateImportSelectionItem)
        title = items.isEmpty ? Constants.emptyTitle : Constants.title
        hideSelection = items.isEmpty
        self.resolver = resolver
        items.selectAll()
    }

    func confirm() {
        if items.isEmpty {
            cancel()
            return
        }
        isImportingCertificates = true
        existingAndSelectedTokensHaveMoreThan20Holders()
            .done { moreThan20Holders in
                if moreThan20Holders {
                    self.isImportingCertificates = false
                    self.router.showTooManyHoldersError()
                } else {
                    self.updateSelectedTokens()
                }
            }
    }

    private func existingAndSelectedTokensHaveMoreThan20Holders() -> Guarantee<Bool> {
        Guarantee { seal in
            vaccinationRepository
                .getCertificateList()
                .map(\.certificates)
                .done { existingTokens in
                    let hasMoreThan20Holders = (existingTokens + self.selectedTokens).hasMoreThan20Holders
                    seal(hasMoreThan20Holders)
                }
                .catch { _ in
                    seal(false)
                }
        }
    }

    private func updateSelectedTokens() {
        vaccinationRepository
            .update(selectedTokens)
            .done { [weak self] _ in
                self?.handleSuccess()
            }
            .ensure { [weak self] in
                self?.isImportingCertificates = false
            }
            .catch { [weak self] _ in
                self?.cancel()
            }
    }

    private func handleSuccess() {
        router
            .showImportSuccess()
            .done { [weak self] _ in
                self?.resolver.fulfill_()
            }
            .cauterize()
    }

    func cancel() {
        resolver.fulfill_()
    }

    func toggleSelection() {
        if selectedItems.count == items.count {
            items.deselectAll()
        } else {
            items.selectAll()
        }
    }
}

private extension ExtendedCBORWebToken {
    var certificateImportSelectionItem: CertificateImportSelectionItem {
        let item: CertificateImportSelectionItem =
            VaccinationImportSelectionItem(token: self) ??
            RecoveryImportSelectionItem(token: self) ??
            TestImportSelectionItem(token: self) ??
            CertificateImportSelectionItem(
                title: vaccinationCertificate.hcert.dgc.nam.fullName,
                subtitle: "",
                additionalLines: [],
                token: self
            )

        return item
    }

    static func sortByFirstName(token1: Self, token2: Self) -> Bool {
        guard let gnt1 = token1.vaccinationCertificate.hcert.dgc.nam.gnt else {
            return false
        }
        guard let gnt2 = token2.vaccinationCertificate.hcert.dgc.nam.gnt else {
            return true
        }

        return gnt1 < gnt2
    }
}

private extension Array where Element == ExtendedCBORWebToken {
    var hasMoreThan20Holders: Bool {
        partitionedByOwner.count > 20
    }
}

private extension Array where Element == CertificateImportSelectionItem {
    func selectAll() {
        forEach { $0.selected = true }
    }

    func deselectAll() {
        forEach { $0.selected = false }
    }
}
