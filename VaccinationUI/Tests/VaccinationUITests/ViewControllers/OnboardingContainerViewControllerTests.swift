//
//  OnboardingContainerViewControllerTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import PromiseKit
import XCTest

class OnboardingContainerViewControllerTests: XCTestCase {
    var sut: OnboardingContainerViewController!
    var viewModel: OnboardingContainerViewModel!

    override func setUp() {
        super.setUp()

        let pageModels = OnboardingPageViewModelType.allCases.map { OnboardingPageViewModel(type: $0) }
        viewModel = OnboardingContainerViewModel(router: OnboardingRouterMock(sceneCoordinator: SceneCoordinatorMock()), items: pageModels)
        sut = OnboardingContainerViewController.createFromStoryboard(bundle: UIConstants.bundle)
        sut.viewModel = viewModel
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        viewModel = nil
        sut = nil

        super.tearDown()
    }

    func testOutlets() {
        XCTAssertNotNil(sut.toolbarView)
        XCTAssertNotNil(sut.pageIndicator)
    }

    func testViewDidLoad() {
        XCTAssertEqual(sut.toolbarView.primaryButton.title, viewModel.startButtonTitle)

        XCTAssertEqual(sut.pages.count, viewModel.items.count)
        XCTAssertEqual(sut.pageIndicator.numberOfDots, sut.pages.count)
    }
}
