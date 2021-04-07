//
//  WindowDelegateMock.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation

class WindowDelegateMock: WindowDelegate {
    
    var updateCalled = false
    
    func update(rootViewController: UIViewController) {
        updateCalled = true
    }
}
