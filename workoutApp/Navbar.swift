//
//  Navbar.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 03/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

// FIXME: - Delete

extension UINavigationController {
    
    func addXButton() {
        
        let navButtonRight = UIImage(named: "xmarkDarkBlue")?.withRenderingMode(.alwaysOriginal)
        let rightButton = UIBarButtonItem(image: navButtonRight, style: .done, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = rightButton
    }
}
