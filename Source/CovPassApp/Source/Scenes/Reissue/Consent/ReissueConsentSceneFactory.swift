import UIKit
import PromiseKit
import CovPassUI
import CovPassCommon

struct ReissueConsentSceneFactory: ResolvableSceneFactory {
    
    // MARK: - Properties
    
    private let router: ReissueConsentRouterProtocol
    private let tokens: [ExtendedCBORWebToken]

    // MARK: - Lifecycle
    
    init(router: ReissueConsentRouterProtocol,
         tokens: [ExtendedCBORWebToken]) {
        self.router = router
        self.tokens = tokens
    }
    
    func make(resolvable: Resolver<Void>) -> UIViewController {
        guard let repository = CertificateReissueRepository() else {
            fatalError("Failed to instantiate repository.")
        }
        let viewModel = ReissueConsentViewModel(router: router,
                                                resolver: resolvable,
                                                tokens: tokens,
                                                repository: repository,
                                                decoder: JSONDecoder())
        let viewController = ReissueConsentViewController(viewModel: viewModel)
        return viewController
    }
}
