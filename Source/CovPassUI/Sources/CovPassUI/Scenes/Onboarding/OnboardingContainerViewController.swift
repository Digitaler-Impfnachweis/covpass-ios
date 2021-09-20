//
//  OnboardingContainerViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public class OnboardingContainerViewController: UIViewController, ViewModelDelegate {
    // MARK: - IBOutlets

    @IBOutlet var bottomView: UIView!
    @IBOutlet var toolbarView: CustomToolbarView!
    @IBOutlet var pageIndicator: DotPageIndicator!
    @IBOutlet var containerView: UIView!

    // MARK: - Public Properties

    private(set) var viewModel: OnboardingContainerViewModel

    // MARK: - Internal Properties

    var pageController: UIPageViewController?
    var pages: [UIViewController] = []
    var currentIndex: Int = 0 {
        didSet {
            // brute force selection of the first element of an onboarding page
            let first = pages[currentIndex].accessibilityElements?.first
            UIAccessibility.post(notification: .layoutChanged, argument: first)
        }
    }

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    public init(viewModel: OnboardingContainerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundPrimary

        viewModel.items.forEach { model in
            var pageViewModel = model
            pageViewModel.delegate = self
            var pageViewController: UIViewController
            switch pageViewModel {
            case let consentViewModel as ConsentPageViewModel:
                let viewController = ConsentViewController(viewModel: consentViewModel)
                viewController.infoViewAction = viewModel.router.showDataPrivacyScene
                pageViewController = viewController
            default:
                let viewController = OnboardingPageViewController(viewModel: pageViewModel)
                pageViewController = viewController
            }
            pages.append(pageViewController)
        }
        configureToolbarView()
        configurePageIndicator()
        configurePageController()
        configureBottomView()
    }

    public func viewModelDidUpdate() {
        updateToolbarForPage(at: currentIndex)
    }

    override public func viewWillAppear(_ animated: Bool) {
        // brute force but works atm
        let first = pages[currentIndex].accessibilityElements?.first
        UIAccessibility.post(notification: .layoutChanged, argument: first)

        super.viewWillAppear(animated)
    }

    public func viewModelUpdateDidFailWithError(_: Error) {}

    // MARK: - Private

    private func configureToolbarView() {
        updateToolbarForPage(at: currentIndex)
        toolbarView.setUpLeftButton(leftButtonItem: .navigationArrow)
        toolbarView.delegate = self
    }

    private func configureBottomView() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bottomView.bounds
        gradientLayer.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor.backgroundPrimary.cgColor, UIColor.backgroundPrimary.cgColor]
        bottomView.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func configurePageIndicator() {
        pageIndicator.numberOfDots = pages.count
        pageIndicator.delegate = self
    }

    private func configurePageController() {
        let viewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.pinEdges(to: containerView)
        viewController.dataSource = self
        viewController.delegate = self
        viewController.setViewControllers([pages[currentIndex]], direction: .forward, animated: false, completion: nil)
        pageController = viewController
    }

    private func updateToolbarForPage(at index: Int) {
        let state = viewModel.items[index].toolbarState
        toolbarView.state = state
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingContainerViewController: UIPageViewControllerDataSource {
    public func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController),
              index > 0 else { return nil }

        return pages[index - 1]
    }

    public func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController),
              index < pages.count - 1 else { return nil }

        return pages[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingContainerViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating _: Bool, previousViewControllers _: [UIViewController], transitionCompleted _: Bool) {
        guard let currentViewController = pageViewController.viewControllers?.first,
              let index = pages.firstIndex(of: currentViewController) else { return }

        currentIndex = index
        updateToolbarForPage(at: index)
        pageIndicator.selectDot(withIndex: index)
    }
}

// MARK: - DotPageIndicatorDelegate

extension OnboardingContainerViewController: DotPageIndicatorDelegate {
    public func dotPageIndicator(_: DotPageIndicator, didTapDot index: Int) {
        guard index != currentIndex, index >= 0, index < pages.count else { return }

        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
        pageController?.setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
        currentIndex = index
    }
}

// MARK: - CustomToolbarViewDelegate

extension OnboardingContainerViewController: CustomToolbarViewDelegate {
    public func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .navigationArrow:
            guard currentIndex - 1 >= 0 else {
                viewModel.navigateToPreviousScene()
                return
            }
            pageController?.setViewControllers([pages[currentIndex - 1]], direction: .reverse, animated: true, completion: { [weak self] _ in
                self?.currentIndex -= 1 // HACK: set here to prevent crashes due to unloaded view
                self?.updateToolbarForPage(at: self?.currentIndex ?? 0)
            })
            pageIndicator.selectDot(withIndex: currentIndex - 1)
        case .textButton:
            guard currentIndex + 1 < pages.count else {
                viewModel.navigateToNextScene()
                return
            }
            pageController?.setViewControllers([pages[currentIndex + 1]], direction: .forward, animated: true, completion: { [weak self] _ in
                self?.currentIndex += 1 // HACK: set here to prevent crashes due to unloaded view
                self?.updateToolbarForPage(at: self?.currentIndex ?? 0)
            })
            pageIndicator.selectDot(withIndex: currentIndex + 1)
        case .scrollButton:
            (pages[currentIndex] as? ConsentViewController)?.scrollToBottom()
        default:
            return
        }
        updateToolbarForPage(at: currentIndex)
    }
}
