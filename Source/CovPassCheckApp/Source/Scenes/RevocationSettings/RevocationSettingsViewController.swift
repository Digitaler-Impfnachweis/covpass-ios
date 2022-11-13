import UIKit
import CovPassUI

class RevocationSettingsViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var labelSwitchView: LabeledSwitch!
    
    private(set) var viewModel: RevocationSettingsViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: RevocationSettingsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        updateView()
        configureView()
    }
    
    private func configureView() {
        view.backgroundColor = .backgroundPrimary
        labelSwitchView.switchChanged = viewModel.switchChanged
        labelSwitchView.uiSwitch.isOn = viewModel.switchState

        let backButton = UIBarButtonItem(image: .arrowBack, style: .done, target: self, action: #selector(backButtonTapped))
        backButton.accessibilityLabel = "accessibility_app_information_contact_label_back".localized // TODO change accessibility text when they are available
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = .onBackground100
    }

    // MARK: - Methods
    
    func updateView() {
        title = viewModel.titleText
        descriptionLabel.attributedText = viewModel.descriptionText.styledAs(.body)
        labelSwitchView.label.attributedText = viewModel.labelText.styledAs(.header_3)
        labelSwitchView.updateAccessibility()
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension RevocationSettingsViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        updateView()
    }

    func viewModelUpdateDidFailWithError(_: Error) {
        // already handled in ViewModel
    }
}
