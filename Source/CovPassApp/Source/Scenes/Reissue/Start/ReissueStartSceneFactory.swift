import UIKit
import PromiseKit
import CovPassUI
import CovPassCommon

struct ReissueStartSceneFactory: ResolvableSceneFactory {
    
    // MARK: - Properties
    
    private let router: ReissueStartRouterProtocol
    private let tokens: [ExtendedCBORWebToken]

    // MARK: - Lifecycle
    
    init(router: ReissueStartRouterProtocol,
         tokens: [ExtendedCBORWebToken]) {
        self.router = router
        self.tokens = tokens
    }
    
    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = ReissueStartViewModel(router: router,
                                              resolver: resolvable,
                                              tokens: tokens)
        let viewController = ReissueStartViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
