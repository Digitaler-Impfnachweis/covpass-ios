import PromiseKit
import UIKit
import CovPassCommon

public struct ResultViewSceneFactory: SceneFactory {
    
    private let router: ResultViewRouterProtocol!
    private let resolver: Resolver<Void>

    // MARK: - Lifecycle

    public init(router: ResultViewRouterProtocol,
                resolver: Resolver<Void>) {
        self.router = router
        self.resolver = resolver
    }

    // MARK: - Methods

    public func make() -> UIViewController {
        let viewModel = ResultViewViewModel(router: router, resolver: resolver)
        let viewController = ResultViewViewController(viewModel: viewModel)
        return viewController
    }
}
