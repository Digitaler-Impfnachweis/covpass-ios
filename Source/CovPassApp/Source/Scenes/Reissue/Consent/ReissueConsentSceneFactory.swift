import UIKit
import PromiseKit
import CovPassUI
import CovPassCommon

struct ReissueConsentSceneFactory: ResolvableSceneFactory {
    
    // MARK: - Properties
    
    let router: ReissueConsentRouterProtocol
    let token: ExtendedCBORWebToken

    // MARK: - Lifecycle
    
    init(router: ReissueConsentRouterProtocol,
         token: ExtendedCBORWebToken) {
        self.router = router
        self.token = token
    }
    
    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = ReissueConsentViewModel(router: router,
                                                resolver: resolvable,
                                                token: token)
        let viewController = ReissueConsentViewController(viewModel: viewModel)
        return viewController
    }
}
