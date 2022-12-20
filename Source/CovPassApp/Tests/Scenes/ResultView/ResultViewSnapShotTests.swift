@testable import CovPassApp
import CovPassUI
import PromiseKit
import XCTest

class ResultViewSnapShotTests: BaseSnapShotTests {
    func testRevokedCertificate() throws {
        let (_, resolver) = Promise<Void>.pending()
        let viewModel = ReissueSuccessViewViewModel(resolver: resolver,
                                                    router: ResultViewRouterMock(),

                                                    certificate: try .mock())
        let viewController = ResultViewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, height: 800)
    }
}
