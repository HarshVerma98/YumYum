//
//  UIBarButton+Hide.swift
//  Snacky
//
//  Created by Harsh Verma on 25/07/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import Foundation
import UIKit
extension UIBarButtonItem {
    func hide() {
        self.isEnabled = false
        self.tintColor = .clear
    }
}
