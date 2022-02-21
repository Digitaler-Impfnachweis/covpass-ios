import UIKit
import CovPassUI

class ReissueConsentViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var certStack: UIStackView!
    @IBOutlet var hintView: HintView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dataPrivacyLabel: ListItemView!
    @IBOutlet var agreeButton: MainButton!
    @IBOutlet var disagreeButton: MainButton!
    
    private(set) var viewModel: ReissueConsentViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ReissueConsentViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        updateView()
        configureActions()
    }

    // MARK: - Methods
    
    private func configureActions() {
        agreeButton.action = viewModel.processAgree
        disagreeButton.action = viewModel.processDisagree
        dataPrivacyLabel.action = viewModel.processPrivacyStatement
    }

    private func configureHintView() {
        hintView.isHidden = false
        hintView.containerView.backgroundColor = .brandAccent10
        hintView.containerView.layer.borderColor = UIColor.brandAccent20.cgColor
        hintView.iconView.image = .infoSignal
        hintView.titleLabel.attributedText = viewModel.hintTitle.styledAs(.header_3)
        hintView.bodyLabel.attributedText = viewModel.hintText
        hintView.enableAccessibility(label: " ", traits: .staticText)
        hintView.setConstraintsToEdge()
    }
    
    func updateView() {
        titleLabel.attributedText = viewModel.titleText.styledAs(.header_2)
        subTitleLabel.attributedText = viewModel.subTitleText.styledAs(.header_3).colored(.onBackground70)
        certStack.subviews.forEach { $0.removeFromSuperview() }
        viewModel.certItems.forEach { certStack.addArrangedSubview($0) }
        configureHintView()
        descriptionLabel.attributedText = viewModel.descriptionText.styledAs(.body)
        dataPrivacyLabel.textLabel.attributedText = viewModel.dataPrivacyText.styledAs(.header_3)
        dataPrivacyLabel.imageView.image = viewModel.dataPrivacyChecvron
        dataPrivacyLabel.showSeperator = true
        agreeButton.title = viewModel.buttonAgreeTitle
        disagreeButton.title = viewModel.buttonDisagreeTitle
    }
    
 }

extension ReissueConsentViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        updateView()
    }

    func viewModelUpdateDidFailWithError(_: Error) {
        // already handled in ViewModel
    }
}
