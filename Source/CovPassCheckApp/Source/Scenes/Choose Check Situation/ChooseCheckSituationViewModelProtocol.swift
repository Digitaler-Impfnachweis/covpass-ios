import CovPassUI
import UIKit

protocol ChooseCheckSituationViewModelProtocol {
    var title: String { get }
    var subtitle: String { get }
    var withinGermanyTitle: String { get }
    var withinGermanySubtitle : String { get }
    var withinGermanyImage: UIImage { get }
    var enteringGermanyTitle: String { get }
    var enteringGermanySubtitle: String { get }
    var enteringGermanyImage: UIImage { get }
    var hintText: String { get }
    var hintImage: UIImage { get }
    var buttonTitle: String { get }
    var openAnnounce: String { get }
    var closeAnnounce: String { get }
    var withinGermanyOptionAccessibiliyLabel: String { get }
    var enteringGermanyOptionAccessibiliyLabel: String { get }
    var delegate: ViewModelDelegate? { get set }
    func withinGermanyIsChoosen()
    func enteringGermanyViewIsChoosen()
    func applyChanges()
}
