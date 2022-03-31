import UIKit
import PromiseKit
import CovPassUI
import CovPassCommon

struct ReissueConsentSceneFactory: SceneFactory {
    
    // MARK: - Properties
    
    private let router: ReissueConsentRouterProtocol
    private let tokens: [ExtendedCBORWebToken]
    private let resolver: Resolver<Void>
    
    // MARK: - Lifecycle
    
    init(router: ReissueConsentRouterProtocol,
         tokens: [ExtendedCBORWebToken],
         resolver: Resolver<Void>) {
        self.router = router
        self.tokens = tokens
        self.resolver = resolver
    }
    
    func make() -> UIViewController {
        guard let reissueRepository = CertificateReissueRepository() else {
            fatalError("Failed to instantiate repository.")
        }
        let vaccinationRepository = VaccinationRepository.create()
        let viewModel = ReissueConsentViewModel(router: router,
                                                resolver: resolver,
                                                tokens: tokens,
                                                reissueRepository: reissueRepository,
                                                vaccinationRepository: vaccinationRepository,
                                                decoder: JSONDecoder(),
                                                locale: .current
        )
        let viewController = ReissueConsentViewController(viewModel: viewModel)
        return viewController
    }
}
