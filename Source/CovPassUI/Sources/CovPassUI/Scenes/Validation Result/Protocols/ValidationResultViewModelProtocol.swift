//
//  File.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import UIKit
import PromiseKit

public protocol ValidationViewModelProtocol {
    var resolvable: Resolver<ExtendedCBORWebToken> { get set }
    var router: ValidationResultRouterProtocol { get set }
    var repository: VaccinationRepositoryProtocol { get set }
    var revocationRepository: CertificateRevocationRepositoryProtocol? { get }
    var audioPlayer: AudioPlayerProtocol? { get }
    var certificate: ExtendedCBORWebToken? { get set }
    var delegate: ResultViewModelDelegate? { get set }
    var toolbarState: CustomToolbarState { get }
    var countdownTimerModel: CountdownTimerModel? { get }
    var icon: UIImage? { get }
    var resultTitle: String { get }
    var resultBody: String { get }
    var paragraphs: [Paragraph] { get }
    var info: String? { get }
    var revocationHeadline: String { get }
    var revocationInfoText: String { get }
    var buttonHidden: Bool { get set }
    var isLoadingScan: Bool { get set }
    var _2GContext: Bool { get set }
    var revocationInfoHidden: Bool { get }
    var userDefaults: Persistence { get }
    var revocationKeyFilename: String { get }
    func scanCertificate()
    func scanCertificateStarted()
    func scanCertificateEnded()
    func revocationButtonTapped()
}
