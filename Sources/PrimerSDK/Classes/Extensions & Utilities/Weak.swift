//
//  Weak.swift
//  PrimerSDK
//
//  Created by Evangelos on 23/2/22.
//

#if canImport(UIKit)

import Foundation

internal class Weak<T: AnyObject> {
    weak var value : T?
    init (value: T) {
        self.value = value
    }
}

#endif
