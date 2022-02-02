//
//  File.swift
//  
//
//  Created by Fatih Karakurt on 20.01.22.
//

import CovPassCommon
import UIKit

public protocol ValidationViewModel {
    var router: ValidationResultRouterProtocol { get set }
    var repository: VaccinationRepositoryProtocol { get set }
    var certificate: CBORWebToken? { get set }
    var delegate: ResultViewModelDelegate? { get set }
    var toolbarState: CustomToolbarState { get }
    var icon: UIImage? { get }
    var resultTitle: String { get }
    var resultBody: String { get }
    var paragraphs: [Paragraph] { get }
    var info: String? { get }
    var buttonHidden: Bool { get set }
    var _2GContext: Bool { get set }
    var userDefaults: Persistence { get }
    func scanNextCertifcate()
}
