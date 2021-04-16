//
//  ModelMappingProtocol.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

/// Generic protocol to support model mapping
public protocol ModelMappingProtocol {
    associatedtype RelatedModel
    init(with model: RelatedModel) throws
}
