//
//  File.swift
//  
//
//  Created by Sebastian Maschinski on 06.05.21.
//

import Foundation

public protocol AppInformationViewModelProtocol {
    var router: AppInformationRouterProtocol { get }
    var title: String { get }
    var descriptionText: String { get }
    var appVersionText: String { get }
    var entries: [AppInformationEntry] { get }

    func showSceneForEntry(_ entry: AppInformationEntry)
}
