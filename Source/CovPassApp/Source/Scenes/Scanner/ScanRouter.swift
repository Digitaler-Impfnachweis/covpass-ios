//
//  ScanRouter.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit

private enum Constants {
    enum Keys {
        static let actionTitleDocument = "file_import_menu_document".localized
        static let actionTitlePhoto = "file_import_menu_photo".localized
        static let actionSheetTitle = "file_import_menu_title".localized
        static let actionTitleCancel = "file_import_menu_cancel".localized
    }
}

struct ScanRouter: ScanRouterProtocol, RouterProtocol {
    public let sceneCoordinator: SceneCoordinator
    
    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    public func showDocumentPickerSheet() -> Promise<DocumentSheetResult> {
        return .init { resolver in
            let photoCompletion: ((DialogAction) -> Void)? = { action in resolver.fulfill(.photo) }
            let documentCompletion: ((DialogAction) -> Void)? = { action in resolver.fulfill(.document) }
            let photoAction: DialogAction = DialogAction(title: Constants.Keys.actionTitlePhoto, completion: photoCompletion)
            let documentAction: DialogAction = DialogAction(title: Constants.Keys.actionTitleDocument, completion: documentCompletion)
            let cancelAction: DialogAction = DialogAction(title: Constants.Keys.actionTitleCancel, style: .cancel)
            let scene = AlertSceneFactory(
                title: Constants.Keys.actionSheetTitle,
                message: nil,
                actions: [photoAction, documentAction, cancelAction],
                style: .actionSheet
            )
            sceneCoordinator.present(scene).cauterize()
        }
        
    }

    public func showCertificatePicker(tokens: [ExtendedCBORWebToken]) -> Promise<Void> {
        sceneCoordinator.present(
            CertificateImportSelectionFactory(
                importTokens: tokens,
                router: CertificateImportSelectionRouter(
                    sceneCoordinator: sceneCoordinator
                )
            )
        )
    }
}
