//
//  UIResponder.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 09/10/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


public extension UIResponder {
    
    private struct Static {
        static weak var responder: UIResponder?
    }
    
    public static func currentFirst() -> UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil) // "to nil" gjør firstResponder blir targetted
        return Static.responder
    }
    
    @objc private func _trap() {
        Static.responder = self
    }
}
