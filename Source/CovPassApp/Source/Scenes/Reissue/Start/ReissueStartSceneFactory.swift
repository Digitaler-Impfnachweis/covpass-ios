import UIKit
import PromiseKit
import CovPassUI
import CovPassCommon

struct ReissueStartSceneFactory: ResolvableSceneFactory {
    
    // MARK: - Properties
    
    let router: ReissueStartRouterProtocol
    let token: ExtendedCBORWebToken

    // MARK: - Lifecycle
    
    init(router: ReissueStartRouterProtocol,
         token: ExtendedCBORWebToken) {
        self.router = router
        self.token = token
    }
    
    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = ReissueStartViewModel(router: router,
                                              resolver: resolvable,
                                              token: token)
        let viewController = ReissueStartViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
