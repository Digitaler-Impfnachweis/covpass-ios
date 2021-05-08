//
//  CertificateRouter.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import Scanner
import UIKit
import VaccinationCommon
import VaccinationUI

class CertificateRouter: CertificateRouterProtocol, DialogRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showCertificates(_ certificates: [ExtendedCBORWebToken]) {
        sceneCoordinator.push(
            VaccinationDetailSceneFactory(
                router: VaccinationDetailRouter(sceneCoordinator: sceneCoordinator),
                repository: VaccinationRepository(service: APIService(), parser: QRCoder()),
                certificates: certificates
            )
        )
    }

    func showProof() -> Promise<Void> {
        sceneCoordinator.present(
            ProofSceneFactory(
                router: ProofRouter(sceneCoordinator: sceneCoordinator)
            )
        )
    }

    func scanQRCode() -> Promise<ScanResult> {
        sceneCoordinator.present(
            ScanSceneFactory()
        )
    }

    func showAppInformation() {
        sceneCoordinator.push(
            PassAppInformationSceneFactory(
                router: AppInformationRouter(sceneCoordinator: sceneCoordinator)
            )
        )
    }

    func showErrorDialog() {
        showDialog(
            title: "error_standard_unexpected_title".localized,
            message: "error_standard_unexpected_message".localized,
            actions: [DialogAction(title: "error_connect_to_internet_Button_ok".localized)],
            style: .alert
        )
    }
}
