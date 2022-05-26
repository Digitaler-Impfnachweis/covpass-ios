@testable import CovPassApp
import CovPassUI
import XCTest
import PromiseKit

class ResultViewSnapShotTests: BaseSnapShotTests {
    
    func testRevokedCertificate() throws {
        let (_, resolver) = Promise<Void>.pending()
        let viewModel = ResultViewViewModel(router: ResultViewRouterMock(), resolver: resolver)
        let viewController = ResultViewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, height: 800)
    }
}
