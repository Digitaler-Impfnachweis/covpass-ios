import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct ReissueConsentResolvableSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    private let router: ReissueConsentRouterProtocol
    private let tokens: [ExtendedCBORWebToken]
    private let context: ReissueContext

    // MARK: - Lifecycle

    init(router: ReissueConsentRouterProtocol,
         tokens: [ExtendedCBORWebToken],
         context: ReissueContext) {
        self.router = router
        self.tokens = tokens
        self.context = context
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        guard let reissueRepository = CertificateReissueRepository() else {
            fatalError("Failed to instantiate repository.")
        }
        let vaccinationRepository = VaccinationRepository.create()
        let viewModel = ReissueConsentViewModel(router: router,
                                                resolver: resolvable,
                                                tokens: tokens,
                                                reissueRepository: reissueRepository,
                                                vaccinationRepository: vaccinationRepository,
                                                decoder: JSONDecoder(),
                                                locale: .current,
                                                context: context)
        let viewController = ReissueConsentViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
