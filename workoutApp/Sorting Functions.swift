//
//  Sorting Functions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 27/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

// Sortingfunctions
func forewards(s1: Lift, s2: Lift) -> Bool {
    if let date1 = s1.datePerformed, let date2 = s2.datePerformed {
        return !(date1 as Date > date2 as Date)
    }
    return false
}
func backwards(s1: Lift, s2: Lift) -> Bool {
    if let date1 = s1.datePerformed, let date2 = s2.datePerformed {
        return date1 as Date > date2 as Date
    }
    return false
}



