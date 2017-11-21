//
//  ExerciseExtensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 17/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

extension Exercise {
    
    func removeFromAnyWorkouts() {
//        let coreDataManager = CoreDataManager(modelName: "workoutApp")
        CoreDataManager().removeExerciseFromAnyWorkouts(exercise: self)
    }
    
    func setMuscles(_ muscles: [Muscle]) {
        musclesUsed = NSSet(array: muscles)
    }
    
    func getName() -> String {
        return name ?? "NO NAME"
    }

    func getMuscles() -> [Muscle] {

        guard let muscles = musclesUsed else {
            fatalError("had no muscles")
        }
        
        return Array(muscles) as! [Muscle]
    }
    
    func getExerciseStyle() -> ExerciseStyle {
        guard let exerciseStyle = self.style else { fatalError() }
        
        return exerciseStyle
    }
    
    func getMeasurementStyle() -> MeasurementStyle {
        guard let measurementStyle = measurementStyle else {
            fatalError()
        }
        
        return measurementStyle
    }
    
    func isWeighted() -> Bool {
        return getMeasurementStyle().getName() == Constant.measurementStyleNames.weighted
    }
}

extension Sequence where Iterator.Element == Exercise {
    
    func sortedByName() -> [Exercise] {
        return self.sorted { (a, b) -> Bool in
            guard let ac = a.name?.first, let bc = b.name?.first else { return false }
            return ac < bc
        }
    }
}

