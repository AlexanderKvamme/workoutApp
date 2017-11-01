//
//  TimeIntervalExtensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 18/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation


extension TimeInterval {
    /// shortens to "10M", "10H", "10D", "10W" .etc
    func asMinimalString() -> String {
    
        guard self.isNaN == false else { return "NA" }
        
        let s = Int(self)
        let m = Int(s/60)
        let h = Int(m/60)
        let d = Int(h/24)
        
        if d > 0 {
            return "\(d)D"
        } else if h > 0 {
            return "\(h)H"
        } else if m > 0 {
            return "\(m)M"
        } else {
            return "\(s)S"
        }
    }
}

