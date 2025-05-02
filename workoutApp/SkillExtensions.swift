//
//  MuscleExtensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 22/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

extension Skill {
    
    func lastPerformance() -> Date? {
        return self.mostRecentUse?.dateEnded as Date?
    }
    
    func getName() -> String {
        return name ?? "NO NAME"
    }
}

