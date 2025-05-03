//
//  MuscleExtensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 22/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

extension Skill {
    
    func getExercises() -> [Exercise] {
        guard let exerciseSet = usedInExercises as? Set<Exercise> else {
            return []
        }
        return Array(exerciseSet)
    }
    
    func lastPerformance() -> Date? {
        return self.mostRecentUse?.dateEnded as Date?
    }
    
    func getName() -> String {
        return name ?? "NO NAME"
    }
}



extension Collection where Iterator.Element == Skill {

// Returns name if only collection contains 1 muscle, or "MULTIPLE" if several muscles
   func getName() -> String {
       
       if self.count == 0 {
           return "NONE"
       } else if self.count == 1 {
           return self.first!.name!
       }
       return "MULTIPLE"
   }
}
