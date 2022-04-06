//
//  File.swift
//  
//
//  Created by Fatih Karakurt on 20.01.22.
//

import CovPassCommon
import UIKit
import PromiseKit

public protocol ValidationViewModel {
    var resolvable: Resolver<ExtendedCBORWebToken> { get set }
    var router: ValidationResultRouterProtocol { get set }
    var repository: VaccinationRepositoryProtocol { get set }
    var certificate: ExtendedCBORWebToken? { get set }
    var delegate: ResultViewModelDelegate? { get set }
    var toolbarState: CustomToolbarState { get }
    var icon: UIImage? { get }
    var resultTitle: String { get }
    var resultBody: String { get }
    var paragraphs: [Paragraph] { get }
    var info: String? { get }
    var revocationHeadline: String { get }
    var revocationInfoText: String { get }
    var buttonHidden: Bool { get set }
    var _2GContext: Bool { get set }
    var revocationInfoHidden: Bool { get }
    var userDefaults: Persistence { get }
    var revocationKeyFilename: String { get }
    func scanNextCertifcate()
    func revocationButtonTapped()
}
