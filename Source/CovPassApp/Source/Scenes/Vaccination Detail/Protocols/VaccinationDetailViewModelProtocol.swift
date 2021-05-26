//
//  VaccinationDetailViewModelProtocol.swift
//  CovPassApp
//
//  Created by Sebastian Maschinski on 23.05.21.
//  Copyright © 2021 IBM. All rights reserved.
//

import CovPassUI
import UIKit

protocol VaccinationDetailViewModelProtocol {
    var delegate: ViewModelDelegate? { get set }
    var fullImmunization: Bool { get }
    var favoriteIcon: UIImage? { get }
    var name: String { get }
    var birthDate: String { get }
    var immunizationIcon: UIImage? { get }
    var immunizationTitle: String { get }
    var immunizationBody: String { get }
    var immunizationButton: String { get }
    var vaccinations: [VaccinationViewModel] { get }

    func refresh()
    func immunizationButtonTapped()
    func toggleFavorite()
}
