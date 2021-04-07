//
//  OnboardingContainerViewController.swift
//  
//
//  Created by Gabriela Secelean on 06.04.2021.
//

import UIKit

enum OnboardingError: Error {
    case closeError
}

public class OnboardingContainerViewController: UIViewController {
    @IBOutlet var toolbarView: CustomToolbarView!
    @IBOutlet var pageIndicator: DotPageIndicator!
    @IBOutlet var startButtonBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Public Properties

    public var viewModel: OnboardingContainerViewModel!
    public var router: Router!
    
    // MARK: - Internal Properties
    
    var pageController: UIPageViewController!
    var pages: [OnboardingPageViewController] = []
    var currentIndex: Int = 0
    
    // MARK: - Private constants

    private struct LayoutConstants {
        let topStartButtonMargin: CGFloat = 12
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        guard viewModel.items.count > 0 else {
            fatalError("ViewModel should contain at least one page")
        }

        weak var weakSelf = self
        viewModel.items.forEach { model in
            let controller = OnboardingPageViewController.createFromStoryboard(bundle: UIConstants.bundle)
            controller.viewModel = model
            controller.viewDidLoadAction = {
                weakSelf?.updateOnboardingPages()
            }
            
            pages.append(controller)
        }

        configureToolbarView()
        configurePageIndicator()
        configurePageController()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateOnboardingPages()
    }

    // MARK: - Private

    private func configureToolbarView() {
        toolbarView.shouldShowTransparency = false
        toolbarView.state = .confirm(viewModel.startButtonTitle)
        toolbarView.setUpLeftButton(leftButtonItem: .navigationArrow)
        toolbarView.delegate = self
    }

    private func configurePageIndicator() {
        pageIndicator.numberOfDots = pages.count
        pageIndicator.delegate = self
    }

    private func configurePageController() {
        pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        pageController.setViewControllers([pages[currentIndex]], direction: .forward, animated: false, completion: nil)

        addChild(pageController)
        view.insertSubview(pageController.view, at: 0)
        pageController.view.frame = view.bounds
        pageController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pageController.didMove(toParent: self)
    }
    
    private func updateOnboardingPages() {
        pages.forEach { onboardingPageViewController in
            guard let bottomConstraint = onboardingPageViewController.contentBottomConstraint else { return }
            bottomConstraint.constant = startButtonBottomConstraint.constant + toolbarView.primaryButton.frame.height + LayoutConstants().topStartButtonMargin
        }
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingContainerViewController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let onboardingPageViewController = viewController as? OnboardingPageViewController, let index = pages.firstIndex(of: onboardingPageViewController) else {
            return nil
        }

        guard index > 0 else {
            return nil
        }

        return pages[index - 1]
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let onboardingPageViewController = viewController as? OnboardingPageViewController, let index = pages.firstIndex(of: onboardingPageViewController) else {
            return nil
        }

        guard index < pages.count - 1 else {
            return nil
        }

        return pages[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingContainerViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentViewController = pageViewController.viewControllers?.first else {
            return
        }

        guard let onboardingPageViewController = currentViewController as? OnboardingPageViewController, let index = pages.firstIndex(of: onboardingPageViewController) else {
            return
        }

        currentIndex = index
        pageIndicator.selectDot(withIndex: index)
    }
}

// MARK: - DotPageIndicatorDelegate

extension OnboardingContainerViewController: DotPageIndicatorDelegate {
    public func dotPageIndicator(_ dotPageIndicator: DotPageIndicator, didTapDot index: Int) {
        guard index != currentIndex, index >= 0, index < pages.count else {
            return
        }
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
        pageController.setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
        currentIndex = index
    }
}

// MARK: - CustomToolbarViewDelegate

extension OnboardingContainerViewController: CustomToolbarViewDelegate {
    public func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .navigationArrow:
            guard currentIndex-1 >= 0 else { return }
            currentIndex -= 1
            pageController.setViewControllers([pages[currentIndex]], direction: .reverse, animated: true, completion: nil)
            pageIndicator.selectDot(withIndex: currentIndex)
        case .textButton:
            guard currentIndex+1 < pages.count else {
                return router.navigateToNextViewController()
            }
            currentIndex += 1
            pageController.setViewControllers([pages[currentIndex]], direction: .forward, animated: true, completion: nil)
            pageIndicator.selectDot(withIndex: currentIndex)
        default:
            return
        }
    }
}

// MARK: - StoryboardInstantiating

extension OnboardingContainerViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        return UIConstants.Storyboard.Onboarding
    }
}
