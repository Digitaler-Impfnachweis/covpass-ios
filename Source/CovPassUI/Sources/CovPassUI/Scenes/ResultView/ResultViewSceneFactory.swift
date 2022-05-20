import PromiseKit
import UIKit
import CovPassCommon

public struct ResultViewSceneFactory: SceneFactory {
    
    private let router: ResultViewRouterProtocol!
    
    // MARK: - Lifecycle

    public init(router: ResultViewRouterProtocol) {
        self.router = router
    }

    // MARK: - Methods

    public func make() -> UIViewController {
        let viewModel = ResultViewViewModel(router: router)
        let viewController = ResultViewViewController(viewModel: viewModel)
        return viewController
    }
}
