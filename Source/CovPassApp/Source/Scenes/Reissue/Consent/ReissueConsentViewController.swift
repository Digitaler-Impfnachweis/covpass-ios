import UIKit
import CovPassUI

private enum Constants {
    static var customSpacingAfterDescription: CGFloat = 12
}

class ReissueConsentViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var certStack: UIStackView!
    @IBOutlet var hintView: HintView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var privacyHeadlineLabel: UILabel!
    @IBOutlet var dataPrivacyLabel: ListItemView!
    @IBOutlet var agreeButton: MainButton!
    @IBOutlet var disagreeButton: MainButton!
    @IBOutlet var bodyStackView: UIStackView!
    @IBOutlet var activityIndicatorContainerView: UIView!
    private let activityIndicator = DotPulseActivityIndicator(frame: .zero)

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
        configureActivityIndicator()
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
        bodyStackView.setCustomSpacing(Constants.customSpacingAfterDescription, after: descriptionLabel)
        privacyHeadlineLabel.attributedText = viewModel.privacyHeadlineText.styledAs(.body).colored(.onBackground70)
        dataPrivacyLabel.textLabel.attributedText = viewModel.dataPrivacyText.styledAs(.header_3)
        dataPrivacyLabel.imageView.image = viewModel.dataPrivacyChecvron
        dataPrivacyLabel.showSeperator = true
        agreeButton.title = viewModel.buttonAgreeTitle
        disagreeButton.title = viewModel.buttonDisagreeTitle
        showActivityIndicatorIfLoading()
    }

    private func showActivityIndicatorIfLoading() {
        if viewModel.isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        activityIndicatorContainerView.isHidden = !viewModel.isLoading
    }

    private func configureActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorContainerView.addSubview(activityIndicator)
        activityIndicator.heightAnchor.constraint(equalToConstant: 20).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 100).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: activityIndicatorContainerView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: activityIndicatorContainerView.centerYAnchor).isActive = true
    }
 }

extension ReissueConsentViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        updateView()
    }

    func viewModelUpdateDidFailWithError(_: Error) {
        updateView()
    }
}
