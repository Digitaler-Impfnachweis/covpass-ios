import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct ReissueConsentSceneFactory: SceneFactory {
    // MARK: - Properties

    private let router: ReissueConsentRouterProtocol
    private let tokens: [ExtendedCBORWebToken]
    private let resolver: Resolver<Void>
    private let context: ReissueContext

    // MARK: - Lifecycle

    init(router: ReissueConsentRouterProtocol,
         tokens: [ExtendedCBORWebToken],
         resolver: Resolver<Void>,
         context: ReissueContext) {
        self.router = router
        self.tokens = tokens
        self.resolver = resolver
        self.context = context
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
                                                locale: .current,
                                                context: context)
        let viewController = ReissueConsentViewController(viewModel: viewModel)
        return viewController
    }
}
