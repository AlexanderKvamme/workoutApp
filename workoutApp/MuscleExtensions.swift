//
//  MuscleExtensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 22/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

extension Muscle {
    
    func lastPerformance() -> Date? {
        return self.mostRecentUse?.dateEnded as Date?
    }
    
    func getName() -> String {
        return name ?? "NO NAME"
    }
}

 // MARK: Extension to collections of elements
 
 extension Collection where Iterator.Element == Muscle {
 
 // Returns name if only collection contains 1 muscle, or "MULTIPLE" if several muscles
    func getName() -> String {
        
        if self.count == 0 {
            return "NO NAME"
        } else if self.count == 1 {
            return self.first!.name!
        }
        return "MULTIPLE"
    }
}

