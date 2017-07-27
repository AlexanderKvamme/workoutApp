//
//  ArrayPrint.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 26/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

// Testprint arrays of lifts: [Lift] 
extension Sequence where Iterator.Element == Lift {
    func oneLinePrint() {
        var repNumbersSeparatedByCommas: String = ""
        for e in self {
            repNumbersSeparatedByCommas.append("\(e.reps), ")
        }
        print(repNumbersSeparatedByCommas)
    }
}

extension Sequence where Iterator.Element == ExerciseLog {
    func oneLinePrint() {
        print("ExerciseLog array contains")
        
        for x in self {
            print(" - \(x.exerciseDesign?.name ?? "error in oneLinePrint")")
        }
    }
}
