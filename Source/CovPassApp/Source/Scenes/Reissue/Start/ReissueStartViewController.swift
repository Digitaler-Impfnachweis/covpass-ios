import UIKit
import CovPassUI

class ReissueStartViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var certStack: UIStackView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var hintView: HintView!
    @IBOutlet var startButton: MainButton!
    @IBOutlet var laterButton: MainButton!
    
    private(set) var viewModel: ReissueStartViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ReissueStartViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        updateView()
        configureActions()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Methods
    
    private func configureActions() {
        startButton.action = viewModel.processStart
        laterButton.action = viewModel.processLater
    }

    private func configureHintView() {
        hintView.isHidden = false
        hintView.containerView.backgroundColor = .brandAccent10
        hintView.containerView.layer.borderColor = UIColor.brandAccent20.cgColor
        hintView.iconView.image = .infoSignal
        hintView.iconLabel.text = ""
        hintView.iconLabel.isHidden = true
        hintView.titleLabel.attributedText = viewModel.hintText.styledAs(.body) .colored(.onBackground70)
        hintView.enableAccessibility(label: " ", traits: .staticText)
        hintView.subTitleLabel.isHidden = true
        hintView.bodyLabel.isHidden = true
        hintView.iconStackviewCenterYConstraint.isActive = false
        hintView.iconStackViewAlignToTopTile.isActive = true
        hintView.titleSuperViewBottomConstraint.isActive = true
        hintView.setConstraintsToEdge()
        hintView.accessibilityLabel = viewModel.hintText
        hintView.accessibilityTraits = .staticText
    }
    
    func updateView() {
        titleLabel.attributedText = viewModel.titleText.styledAs(.header_2)
        titleLabel.accessibilityTraits = .header
        imageView.image = UIImage.reissue
        certStack.subviews.forEach { $0.removeFromSuperview() }
        certStack.addArrangedSubview(viewModel.certItem)
        descriptionLabel.attributedText = viewModel.descriptionText.styledAs(.body)
        configureHintView()
        startButton.title = viewModel.buttonStartTitle
        laterButton.title = viewModel.buttonLaterTitle
        laterButton.style = .plain
        viewModel.certItem.setupAccessibility()
    }
    
 }

extension ReissueStartViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        updateView()
    }

    func viewModelUpdateDidFailWithError(_: Error) {
        // already handled in ViewModel
    }
}

private extension CertificateItem {
    func setupAccessibility() {
        accessibilityLabel = titleLabel.textableView.text
        accessibilityValue = [
            viewModel.subtitle,
            viewModel.info,
            viewModel.statusIconAccessibilityLabel
        ].compactMap { $0 }.joined(separator: "\n")
    }
}
