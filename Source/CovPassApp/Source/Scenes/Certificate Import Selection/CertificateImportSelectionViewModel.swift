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
    private let vaccinationRepository: VaccinationRepositoryProtocol
    private let resolver: Resolver<Void>

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

    var itemSelectionState: CertificateImportSelectionState {
        switch selectedItems.count {
        case 0:
            return .none
        case 1..<items.count:
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
         resolver: Resolver<Void>
    ) {
        self.vaccinationRepository = vaccinationRepository
        items = tokens
            .sorted(by: ExtendedCBORWebToken.sortByFirstName)
            .map(\.certificateImportSelectionItem)
        title = items.isEmpty ? Constants.emptyTitle : Constants.title
        hideSelection = items.isEmpty
        self.resolver = resolver
        self.items.selectAll()
    }

    func confirm() {
        guard !items.isEmpty else {
            cancel()
            return
        }
#warning("TODO: Incomplete implementation")
        //vaccinationRepository.update...()
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
        let item: CertificateImportSelectionItem
        let dgc = vaccinationCertificate.hcert.dgc

        if let vaccination = dgc.v?.first {
            item = VaccinationImportSelectionItem(
                name: dgc.nam,
                vaccination: vaccination
            )
        } else {
#warning("TODO: Incomplete implementation")
            item = .init(
                title: dgc.nam.fullName,
                subtitle: "MISSING",
                additionalLines: []
            )
        }

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

private extension Array where Element == CertificateImportSelectionItem {
    func selectAll() {
        forEach { $0.selected = true }
    }

    func deselectAll() {
        forEach { $0.selected = false }
    }
}
