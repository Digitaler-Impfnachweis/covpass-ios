//
//  OnboardingPageViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

public class ValidationOnboardingPageViewModel: OnboardingPageViewModel {
    public override var image: UIImage? {
        switch self.type {
        case .page1:
            return UIImage(named: "illustration_2", in: UIConstants.bundle, compatibleWith: nil)
        case .page2:
            return UIImage(named: "illustration_3", in: UIConstants.bundle, compatibleWith: nil)
        default:
            return nil
        }
    }

    public override var title: String {
        switch self.type {
        case .page1:
            return "validation_step1_title".localized
        case .page2:
            return "validation_step2_title".localized
        default:
            return ""
        }
    }

    public override var info: String {
        switch self.type {
        case .page1:
            return "validation_step1_body".localized
        case .page2:
            return "validation_step2_body".localized
        default:
            return ""
        }
    }
}

