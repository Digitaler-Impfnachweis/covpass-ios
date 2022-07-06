//
//  PHPickerResult+PromiseKit.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit

extension Sequence where Element == NSItemProvider {
    func loadImages() -> Promise<[UIImage]> {
        let iterator = map { $0.loadImage() }.makeIterator()
        return when(fulfilled: iterator, concurrently: 1)
            .map { $0.compactMap { $0 } }
    }
}

extension NSItemProvider {
    func loadImage() -> Guarantee<UIImage?> {
        Guarantee { seal in
            if canLoadObject(ofClass: UIImage.self) {
                loadObject(ofClass: UIImage.self) { image, error in
                    guard error == nil, let image = image as? UIImage else {
                        seal(nil)
                        return
                    }
                    seal(image)
                }
            } else {
                seal(nil)
            }
        }
    }
}
