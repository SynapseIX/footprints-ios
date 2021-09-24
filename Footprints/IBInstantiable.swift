//
//  IBInstantiable.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/24/21.
//

import UIKit

protocol IBInstantiable {
    static func instantiate() -> Self
}

// MARK: - Default implementation for UIViewController

extension IBInstantiable where Self: UIViewController {
    static func instantiate() -> Self {
        let nibName = String(describing: self)
        return Self(nibName: nibName, bundle: Bundle.main)
    }
}
