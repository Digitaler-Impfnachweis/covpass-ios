import Foundation
import PromiseKit
import CovPassUI
import CovPassCommon

private enum Constants {
    enum Keys {
        static let titleText = "revocation_headline".localized
        static let descriptionText = "revocation_copy".localized
        static let labelText = "revocation_toggle_text".localized
    }
}

class RevocationSettingsViewModel: RevocationSettingsViewModelProtocol {
    
    // MARK: - Properties
    weak var delegate: ViewModelDelegate?
    let titleText = Constants.Keys.titleText
    let descriptionText = Constants.Keys.descriptionText
    let labelText = Constants.Keys.labelText
    var switchState: Bool { userDefaults.revocationExpertMode }
    private let router: RevocationSettingsRouterProtocol?
    private var userDefaults: Persistence

    // MARK: - Lifecyle
    
    init(router: RevocationSettingsRouterProtocol,
         userDefaults: Persistence) {
        self.router = router
        self.userDefaults = userDefaults
    }
    
    // MARK: - Methods
    
    func switchChanged(isOn: Bool) {
        userDefaults.revocationExpertMode = isOn
    }
}
