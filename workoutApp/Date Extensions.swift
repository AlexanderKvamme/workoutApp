//
//  Date Extensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 27/04/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit


extension Date {
    /// Returns the number of days between this date and the current date
    /// - Returns: Integer representing the number of days that have passed since this date
    func daysSinceNow() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: Date())
        return components.day ?? 0
    }
    
    /// Returns the number of days between this date and another date
    /// - Parameter date: The date to calculate days until
    /// - Returns: Integer representing the number of days between the two dates
    func daysSince(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: date)
        return components.day ?? 0
    }
}
