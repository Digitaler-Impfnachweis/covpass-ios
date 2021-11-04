//
//  CertificateDetailViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassCommon
@testable import CovPassUI
import XCTest
import PromiseKit


class CertificateDetailViewControllerSnapshotTests: BaseSnapShotTests {

    func testCertificateDetailViewController() {
        let (_, resolver) = Promise<CertificateDetailSceneResult>.pending()
        let bl = BoosterLogic.init(certLogic: DCCCertLogicMock(), userDefaults: MockPersistence())
        let vm = CertificateDetailViewModel(router: CertificateDetailRouterMock(), repository: VaccinationRepositoryMock(), boosterLogic: bl, certificates: [try! ExtendedCBORWebToken.mock()], resolvable: resolver)
        let vc = CertificateDetailViewController(viewModel: vm)

        verifyView(view: vc.view, height: 1100)
    }

}

struct CertificateDetailRouterMock: CertificateDetailRouterProtocol {
    func showDetail(for certificate: ExtendedCBORWebToken) -> Promise<CertificateDetailSceneResult> {
        .value(.addNewCertificate)
    }

    func showWebview(_ url: URL) {
        
    }

    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
}
