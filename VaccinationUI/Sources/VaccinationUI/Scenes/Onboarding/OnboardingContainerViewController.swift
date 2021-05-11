//
//  OnboardingContainerViewController.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
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
    var currentIndex: Int = 0

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    public init(viewModel: OnboardingContainerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .neutralWhite

        viewModel.items.forEach { model in
            var pageViewModel = model
            pageViewModel.delegate = self
            var pageViewController: UIViewController
            switch pageViewModel {
            case let consentViewModel as ConsentPageViewModel:
                let viewController = ConsentViewController(viewModel: consentViewModel)
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
        gradientLayer.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor(white: 1, alpha: 0.7).cgColor, UIColor.white.cgColor]
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
            currentIndex -= 1
            pageController?.setViewControllers([pages[currentIndex]], direction: .reverse, animated: true, completion: nil)
            pageIndicator.selectDot(withIndex: currentIndex)
        case .textButton:
            guard currentIndex + 1 < pages.count else {
                viewModel.navigateToNextScene()
                return
            }
            currentIndex += 1
            pageController?.setViewControllers([pages[currentIndex]], direction: .forward, animated: true, completion: nil)
            pageIndicator.selectDot(withIndex: currentIndex)
        default:
            return
        }
        updateToolbarForPage(at: currentIndex)
    }
}
