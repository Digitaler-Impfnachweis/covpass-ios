//
//  FileManager+Simulator.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension FileManager {

    /// Prints out the locations of the simulator and the shared group folder.
    ///
    /// This is useful for debugging file issues.
    /// Example usage: FileManager.default.printFileLocations()
    ///
    /// via: https://gist.github.com/AvdLee/7fd62be9bc8fd11de499a49205d77369
    func printFileLocations() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let simulatorFolder = paths.last!
        let appGroupURL = containerURL(forSecurityApplicationGroupIdentifier: "group.com.your.app")!
        print("🗂 Simulator folder location: \(simulatorFolder) \n App Group Location: \(appGroupURL.path)")
    }
}
