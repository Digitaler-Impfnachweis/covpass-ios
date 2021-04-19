//
//  OnboardingViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

public class OnboardingViewModel: StartOnboardingViewModel {
    
    public override init() {}

    public override var image: UIImage? {
        UIImage(named: UIConstants.IconName.StartScreen, in: UIConstants.bundle, compatibleWith: nil)
    }

    public override var title: String {
        "Willkommen zur Prüf-App für digialte Impfnachweise"
    }

    public override var info: String {
        "Schnell und datensicher die Gültigkeit eines Impfnachweises prüfen."
    }
    
    public override var secureTitle: String {
        "Sicherer Datenaustausch"
    }
    
    public override var secureText: String {
        "Es werden keine persönlichen Daten gespeichert und Sie sehen nur die wirklich notwendigen Informationen."
    }
    
    public override var navigationButtonTitle: String {
        "Jetzt starten"
    }
    
    public override var secureImage: UIImage? {
        UIImage(named: UIConstants.IconName.IconLock, in: UIConstants.bundle, compatibleWith: nil)
    }
}

