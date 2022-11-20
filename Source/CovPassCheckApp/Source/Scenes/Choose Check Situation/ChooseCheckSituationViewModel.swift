import Foundation
import PromiseKit
import CovPassUI
import CovPassCommon
import UIKit

private enum Constants {
    enum Keys {
        static let title = "rules_context_initial_setup_title".localized
        static let openAnnounce = "accessibility_check_context_onboarding_announce_open".localized
        static let closeAnnounce = "accessibility_check_context_onboarding_announce_close".localized
        static let subtitle = "rules_context_initial_setup_subtitle".localized
        static let hint = "rules_context_initial_setup_hint".localized
        static let button = "rules_context_initial_setup_button".localized
        static let withinGermanyTitle = "settings_rules_context_germany_title".localized
        static let withinGermanySubtitle = "settings_rules_context_germany_subtitle".localized
        static let enteringGermanyTitle = "settings_rules_context_entry_title".localized
        static let enteringGermanySubtitle = "settings_rules_context_entry_subtitle".localized
        static let optionSelected = "accessibility_option_selected".localized
        static let optionUnselected = "accessibility_option_unselected".localized
    }
}

class ChooseCheckSituationViewModel: ChooseCheckSituationViewModelProtocol {
    
    // MARK: - Properties
    weak var delegate: ViewModelDelegate?
    
    let title = Constants.Keys.title
    let subtitle = Constants.Keys.subtitle
    let withinGermanyTitle = Constants.Keys.withinGermanyTitle
    let withinGermanySubtitle = Constants.Keys.withinGermanySubtitle
    let enteringGermanyTitle = Constants.Keys.enteringGermanyTitle
    let enteringGermanySubtitle = Constants.Keys.enteringGermanySubtitle
    let hintText = Constants.Keys.hint
    let hintImage: UIImage = .settings
    let buttonTitle = Constants.Keys.button
    let openAnnounce = Constants.Keys.openAnnounce
    let closeAnnounce = Constants.Keys.closeAnnounce
    var withinGermanyImage: UIImage { withinGermanyIsSelected ? .checkboxChecked : .checkboxUnchecked }
    var enteringGermanyImage: UIImage { withinGermanyIsSelected ? .checkboxUnchecked : .checkboxChecked }
    var withinGermanyOptionAccessibiliyLabel: String { withinGermanyIsSelected ? Constants.Keys.optionSelected : Constants.Keys.optionUnselected }
    var enteringGermanyOptionAccessibiliyLabel: String { !withinGermanyIsSelected ? Constants.Keys.optionSelected : Constants.Keys.optionUnselected }

    private let resolver: Resolver<Void>?
    private let router: ChooseCheckSituationRouterProtocol?
    private var persistence: Persistence
    private var selectedCheckSituation: CheckSituationType { didSet { delegate?.viewModelDidUpdate() } }
    private var withinGermanyIsSelected: Bool { selectedCheckSituation == .withinGermany }
    // MARK: - Lifecyle
    
    init(router: ChooseCheckSituationRouterProtocol,
         resolver: Resolver<Void>,
         persistence: Persistence) {
        self.router = router
        self.resolver = resolver
        self.persistence = persistence
        self.selectedCheckSituation = .init(rawValue: persistence.checkSituation) ?? .withinGermany
    }
    
    // MARK: - Methods
    
    func withinGermanyIsChoosen() {
        selectedCheckSituation = .withinGermany
    }
    
    func enteringGermanyViewIsChoosen() {
        selectedCheckSituation = .enteringGermany
    }
    
    func applyChanges() {
        persistence.checkSituation = selectedCheckSituation.rawValue
        resolver?.fulfill_()
    }
    
}
