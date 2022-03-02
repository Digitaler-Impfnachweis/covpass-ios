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
    
    func showNext(newTokens: [ExtendedCBORWebToken],
                  oldTokens: [ExtendedCBORWebToken],
                  resolver: Resolver<Void>){
        sceneCoordinator
            .push(ReissueResultSceneFactory(router: ReissueResultRouter(sceneCoordinator: sceneCoordinator),
                                            newTokens: newTokens,
                                            oldTokens: oldTokens,
                                            resolver: resolver))
    }
    
    func cancel(resolver: Resolver<Void>) {
        showDialog(title: "",
                   message: Constants.Text.Alert.Cancellation.message,
                   actions: [
                    DialogAction(title: Constants.Text.Alert.Cancellation.ok, style: UIAlertAction.Style.default, isEnabled: true, completion: { _ in }),
                    DialogAction(title: Constants.Text.Alert.Cancellation.cancel, style: UIAlertAction.Style.destructive, isEnabled: true, completion: { [weak self] _ in
                        resolver.fulfill_()
                        self?.sceneCoordinator.dimiss(animated: true)
                    })],
                   style: .alert)
    }
    
    func routeToPrivacyStatement() {
        sceneCoordinator
            .push(DataPrivacySceneFactory(router: DataPrivacyRouter(sceneCoordinator: sceneCoordinator)))
            .cauterize()
    }

    func showError(_ error: Error, resolver _: Resolver<Void>) {
        print("\(#file):\(#function) Error: \(error)")
        showDialog(
            title: "error_standard_unexpected_title".localized,
            message: "error_standard_unexpected_message".localized,
            actions: [
                .init(title: "error_standard_unexpected_button_title".localized)
            ],
            style: .alert
        )
    }
}
