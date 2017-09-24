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

// MARK: Sorting

extension Collection where Iterator.Element == Muscle {
    
    func sortedByName() -> [Muscle] {
        return self.sorted(by: { (l, r) -> Bool in
            if let lc = l.name?.characters.first, let rc = l.name?.characters.first {
                return lc < rc
            }
            return true
        })
    }
    
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


