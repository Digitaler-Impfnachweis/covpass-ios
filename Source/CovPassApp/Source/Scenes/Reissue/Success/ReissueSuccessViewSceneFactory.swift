import PromiseKit
import UIKit
import CovPassUI

public struct ReissueSuccessViewSceneFactory: SceneFactory {

    private let resolver: Resolver<Void>

    // MARK: - Lifecycle

    public init(resolver: Resolver<Void>) {
        self.resolver = resolver
    }

    // MARK: - Methods

    public func make() -> UIViewController {
        let viewModel = ReissueSuccessViewViewModel(resolver: resolver)
        let viewController = ResultViewViewController(viewModel: viewModel)
        return viewController
    }
}
