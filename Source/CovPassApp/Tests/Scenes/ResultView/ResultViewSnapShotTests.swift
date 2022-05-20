@testable import CovPassApp
import CovPassUI
import XCTest

class ResultViewSnapShotTests: BaseSnapShotTests {
    
    func testRevokedCertificate() throws {
        let viewModel = ResultViewViewModel(router: ResultViewRouterMock())
        let viewController = ResultViewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, height: 800)
    }
}
