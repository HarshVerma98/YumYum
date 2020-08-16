//
//  View+Border.swift
//  Snacky
//
//  Created by Harsh Verma on 25/07/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit

extension UIView {
    func addBorder(width: CGFloat, radius: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = radius
    }
    
    func noBorder() {
        self.layer.borderWidth = 0.0
    }
}

