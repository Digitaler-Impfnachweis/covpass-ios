import UIKit
import PromiseKit
import CovPassUI
import CovPassCommon

struct RevocationSettingsSceneFactory: SceneFactory {
    
    // MARK: - Properties
    
    private let router: RevocationSettingsRouterProtocol
    private let userDefaults: Persistence
    
    // MARK: - Lifecycle
    
    init(router: RevocationSettingsRouterProtocol,
         userDefaults: Persistence) {
        self.router = router
        self.userDefaults = userDefaults
    }
    
    func make() -> UIViewController {
        let viewModel = RevocationSettingsViewModel(router: router,
                                                    userDefaults: userDefaults)
        let viewController = RevocationSettingsViewController(viewModel: viewModel)
        return viewController
    }
}
