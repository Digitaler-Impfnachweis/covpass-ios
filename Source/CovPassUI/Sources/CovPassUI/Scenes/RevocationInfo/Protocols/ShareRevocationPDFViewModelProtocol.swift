//
//  ShareRevocationPDFViewModelProtocol.swift
//  
//
//  Created by Thomas Kuleßa on 10.03.22.
//

import Foundation

protocol ShareRevocationPDFViewModelProtocol {
    var fileURL: URL { get }
    func handleActivityResult(completed: Bool, activityError: Error?)
}
