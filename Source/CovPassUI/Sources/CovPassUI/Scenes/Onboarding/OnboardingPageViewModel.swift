//
//  OnboardingPageViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import UIKit

public protocol ConsentRouterProtocol: RouterProtocol {
    func showTermsOfUse()
}

public struct ConsentRouter: ConsentRouterProtocol {
    // MARK: - Properties

    public let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    public init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    public func showTermsOfUse() {
        guard let url = Bundle.uiBundle.url(forResource: "us-terms-of-use", withExtension: "html") else { return }
        sceneCoordinator.present(
            WebviewSceneFactory(
                title: "vaccination_fourth_onboarding_page_message_for_us_citizens_title".localized,
                url: url,
                closeButtonShown: true
            ),
            animated: true
        )
    }
}

public enum OnboardingPageViewModelType: CaseIterable {
    case page1
    case page2
    case page3
    case page4
}

public protocol OnboardingPageViewModel {
    var delegate: ViewModelDelegate? { get set }
    var type: OnboardingPageViewModelType { get }
    var toolbarState: CustomToolbarState { get }
    var image: UIImage? { get }
    var title: String? { get }
    var info: String? { get }
}

public protocol ConsentPageViewModel: OnboardingPageViewModel {
    var router: ConsentRouterProtocol { get set }
    var listItems: NSAttributedString { get }
    var dataPrivacyTitle: NSAttributedString { get }
    var isScrolledToBottom: Bool { get set }
    var showUSTerms: Bool { get }
}
