import CovPassUI
import CovPassCommon
import PromiseKit
import UIKit

private enum Constants {
    enum Text {
        enum Alert {
            enum Cancellation {
                static let message = "cancellation_share_certificate_title".localized
                static let ok = "cancellation_share_certificate_action_button_no".localized
                static let cancel = "cancellation_share_certificate_action_button_yes".localized
            }
        }
    }
}

class ReissueConsentRouter: ReissueConsentRouterProtocol, DialogRouterProtocol {

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
    
    func cancel() -> Promise<Bool> {
        .init { resolver in
            showDialog(title: "",
                       message: Constants.Text.Alert.Cancellation.message,
                       actions: [
                        DialogAction(title: Constants.Text.Alert.Cancellation.ok, style: UIAlertAction.Style.default, isEnabled: true, completion: { _ in
                            return resolver.fulfill(false)
                        }),
                        DialogAction(title: Constants.Text.Alert.Cancellation.cancel, style: UIAlertAction.Style.destructive, isEnabled: true, completion: { _ in
                            self.sceneCoordinator.dimiss(animated: true)
                            return resolver.fulfill(true)
                        })],
                       style: .alert)
        }
    }
    
    func routeToPrivacyStatement() {
        sceneCoordinator
            .push(DataPrivacySceneFactory(router: DataPrivacyRouter(sceneCoordinator: sceneCoordinator)))
            .cauterize()
    }
}
