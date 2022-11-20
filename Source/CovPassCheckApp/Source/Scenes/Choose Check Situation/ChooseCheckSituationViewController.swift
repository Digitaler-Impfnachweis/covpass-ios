import UIKit
import CovPassUI

class ChooseCheckSituationViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet var headerView: InfoHeaderView!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var withinGermanyView: ImageTitleSubtitleView!
    @IBOutlet var enteringGermanyView: ImageTitleSubtitleView!
    @IBOutlet var hintView: ImageTitleSubtitleView!
    @IBOutlet var applyButton: MainButton!
    
    private(set) var viewModel: ChooseCheckSituationViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ChooseCheckSituationViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.openAnnounce)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.closeAnnounce)
    }

    // MARK: - Methods
    
    func updateView() {
        headerView.attributedTitleText = viewModel.title.styledAs(.header_1)
        headerView.actionButton.isHidden = true
        headerView.actionButton.isAccessibilityElement = false
        subtitleLabel.attributedText = viewModel.subtitle.styledAs(.body)
        updateHint()
        updateButton()
        updateWithinGermany()
        updateEnteringGermany()
    }
    
    func updateWithinGermany() {
        let title = viewModel.withinGermanyTitle.styledAs(.header_3)
        let subtitle = viewModel.withinGermanySubtitle.styledAs(.body)
        let image = viewModel.withinGermanyImage
        withinGermanyView.update(title: title,
                                 subtitle: subtitle,
                                 rightImage: image,
                                 backGroundColor: .clear,
                                 edgeInstes: .init(top: 12, left: 24, bottom: 12, right: 24))
        withinGermanyView.onTap = {
            self.viewModel.withinGermanyIsChoosen()
            UIAccessibility.post(notification: .layoutChanged, argument: self.viewModel.enteringGermanyOptionAccessibiliyLabel)
        }
        withinGermanyView.containerView?.accessibilityValue = viewModel.withinGermanyOptionAccessibiliyLabel
    }
    
    func updateEnteringGermany() {
        let title = viewModel.enteringGermanyTitle.styledAs(.header_3)
        let subtitle = viewModel.enteringGermanySubtitle.styledAs(.body)
        let image = viewModel.enteringGermanyImage
        enteringGermanyView.update(title: title,
                                   subtitle: subtitle,
                                   rightImage: image,
                                   backGroundColor: .clear,
                                   edgeInstes: .init(top: 12, left: 24, bottom: 12, right: 24))
        enteringGermanyView.onTap = {
            self.viewModel.enteringGermanyViewIsChoosen()
            UIAccessibility.post(notification: .layoutChanged, argument: self.viewModel.enteringGermanyOptionAccessibiliyLabel)
        }
        enteringGermanyView.containerView?.accessibilityValue = viewModel.enteringGermanyOptionAccessibiliyLabel
    }
    
    func updateHint() {
        let title = viewModel.hintText.styledAs(.body)
        let image = viewModel.hintImage
        hintView.update(title: title,
                        leftImage: image,
                        backGroundColor: .clear,
                        imageWidth: 20,
                        edgeInstes: .init(top: 0, left: 0, bottom: 0, right: 0),
                        iconVerticalAlignmentActive: false)
    }
    
    func updateButton() {
        applyButton.style = .primary
        applyButton.title = viewModel.buttonTitle
        applyButton.action = viewModel.applyChanges
    }
 }

extension ChooseCheckSituationViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        updateView()
    }

    func viewModelUpdateDidFailWithError(_: Error) {
        // already handled in ViewModel
    }
}
