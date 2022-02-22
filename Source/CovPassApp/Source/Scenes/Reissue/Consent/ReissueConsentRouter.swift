import CovPassUI
import Foundation
import CovPassCommon

class ReissueConsentRouter: ReissueConsentRouterProtocol {

    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods
    
    func showNext(newToken: ExtendedCBORWebToken,
                  oldToken: ExtendedCBORWebToken) {
        sceneCoordinator
            .push(ReissueResultSceneFactory(router: ReissueResultRouter(sceneCoordinator: sceneCoordinator),
                                            newToken: newToken,
                                            oldToken: oldToken))
            .cauterize()
    }
    
    func cancel() {
        // TODO: show before dismissing are you sure popup with yes/no button. Twine keys atm are not ready
        sceneCoordinator.dimiss(animated: true)
    }
    
    func routeToPrivacyStatement() {
        sceneCoordinator
            .push(DataPrivacySceneFactory(router: DataPrivacyRouter(sceneCoordinator: sceneCoordinator)))
            .cauterize()
    }
}
