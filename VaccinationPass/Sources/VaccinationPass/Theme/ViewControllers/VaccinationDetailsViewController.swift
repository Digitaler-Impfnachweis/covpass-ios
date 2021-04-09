//
//  VaccinationDetailsViewController.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import VaccinationUI
import UIKit

public class VaccinationDetailsViewController: UIViewController {
    @IBOutlet var paragraphView: ParagraphView!

    public var cborData: String?

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        paragraphView.bodyText = cborData
    }
}

extension VaccinationDetailsViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        "Pass"
    }
}
