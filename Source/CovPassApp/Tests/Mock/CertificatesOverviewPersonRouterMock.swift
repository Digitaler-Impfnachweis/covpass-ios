@testable import CovPassApp
import CovPassUI
import PromiseKit
import CovPassCommon
import XCTest

class CertificatesOverviewPersonRouterMock: CertificatesOverviewPersonRouterProtocol {
    
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    var showCertificteExpectation = XCTestExpectation()
    var sceneResult: CertificateDetailSceneResult = .addNewCertificate
    var sceneResultShouldCancel = false

    func showCertificatesDetail(certificates: [ExtendedCBORWebToken]) -> Promise<CertificateDetailSceneResult> {
        if sceneResultShouldCancel {
            return .init { result in
                result.cancel()
            }
        }
        showCertificteExpectation.fulfill()
        return .value(sceneResult)
    }
    
}
