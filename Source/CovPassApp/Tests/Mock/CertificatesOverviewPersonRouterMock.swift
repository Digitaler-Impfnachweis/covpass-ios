@testable import CovPassApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

class CertificatesOverviewPersonRouterMock: CertificatesOverviewPersonRouterProtocol {
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    var showCertificteExpectation = XCTestExpectation()
    var sceneResult: CertificateDetailSceneResult = .addNewCertificate
    var sceneResultShouldCancel = false

    func showCertificatesDetail(certificates _: [ExtendedCBORWebToken]) -> Promise<CertificateDetailSceneResult> {
        if sceneResultShouldCancel {
            return .init { result in
                result.cancel()
            }
        }
        showCertificteExpectation.fulfill()
        return .value(sceneResult)
    }
}
