//
//  UITextField Extensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 10/10/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
 
    func hasText() -> Bool {
        guard let text = self.text else {
            return false
        }
        return text != ""
    }
    
    func isEmpty() -> Bool {
        guard let text = self.text else {
            return true
        }
        
        return text == ""
    }
}
