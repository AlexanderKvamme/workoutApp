//
//  UIStackViewExtensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 23/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


extension UIStackView {
    func removeArrangedSubviews() {
        for arrangedSubView in self.arrangedSubviews {
            arrangedSubView.removeFromSuperview()
        }
    }
}
