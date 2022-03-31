import CovPassUI

protocol RevocationSettingsViewModelProtocol {
    var delegate: ViewModelDelegate? { get set }
    var titleText: String { get }
    var descriptionText: String { get }
    var labelText: String { get }
    var switchState: Bool { get }
    func switchChanged(isOn: Bool)
}
