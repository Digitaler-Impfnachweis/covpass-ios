import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

public struct ReissueSuccessViewSceneFactory: SceneFactory {
    private let resolver: Resolver<Void>
    private let router: ResultViewRouterProtocol
    private let certificate: ExtendedCBORWebToken

    // MARK: - Lifecycle

    public init(resolver: Resolver<Void>,
                router: ResultViewRouterProtocol,
                certificate: ExtendedCBORWebToken) {
        self.resolver = resolver
        self.router = router
        self.certificate = certificate
    }

    // MARK: - Methods

    public func make() -> UIViewController {
        let viewModel = ReissueSuccessViewViewModel(resolver: resolver, router: router, certificate: certificate)
        let viewController = ResultViewViewController(viewModel: viewModel)
        return viewController
    }
}
