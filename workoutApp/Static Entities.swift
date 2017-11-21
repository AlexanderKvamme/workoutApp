//
//  Static Entities.swift
//  workoutAppTests
//
//  Created by Alexander Kvamme on 21/11/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

/// Easily accessible for quickly seeding before generating snapshots .etc
final class MeasurementStyles {
    
    let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    // Computed Properties
    
    var sets: MeasurementStyle {
        return getOrMakeMeasurementStyle(named: "SETS")
    }
    
    // time
    var time: MeasurementStyle {
        return getOrMakeMeasurementStyle(named: "TIME")
    }
    
    // weighted sets
    var weightedSets: MeasurementStyle {
        return getOrMakeMeasurementStyle(named: "WEIGHTED SETS")
    }
    
    // Methods
    private func getOrMakeMeasurementStyle(named name: String) -> MeasurementStyle {
        return coreDataManager.getMeasurementStyle(named: name) ?? coreDataManager.makeMeasurementStyle(named: name)
    }
}

/// Easily accessible for quickly seeding before generating snapshots .etc
final class Exercises {
    
    let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    // Computed Properties
    
    var pullUp: Exercise {
        return getOrMakeExercise(named: "PULL UP")
    }
    
    var bicepFlex: Exercise {
        return getOrMakeExercise(named: "BICEP FLEX")
    }
    
    var tricepsFlex: Exercise {
        return getOrMakeExercise(named: "TRICEPS FLEX")
    }
    
    var weightedPullUp: Exercise {
        let muscles = Muscles(coreDataManager: coreDataManager)
        let measurementStyles = MeasurementStyles(coreDataManager: coreDataManager)
        let exerciseStyles = ExerciseStyles(coreDataManager: coreDataManager)
        let name = "WEIGHTED PULL UP"
        
        return coreDataManager.getExercise(named: name) ??  coreDataManager.makeExercise(withName: name, exerciseStyle: exerciseStyles.weighted, muscles: [muscles.chest], measurementStyle: measurementStyles.weightedSets)
    }
    
    var WMSPullUp: Exercise {
        return getOrMakeExercise(named: "WMS AUS PULL")
    }
    
    var chestToBar: Exercise {
        return getOrMakeExercise(named: "CHEST TO BAR")
    }
    
    var assistedChestToBar: Exercise {
        return getOrMakeExercise(named: "ASSISTED CHEST TO BAR")
    }
    
    var negativeMuscleUp: Exercise {
        return getOrMakeExercise(named: "NEGATIVE MUSCLE UP")
    }
    
    // Methods
    
    /// Helper to make a quick unweighted exercise
    private func getOrMakeExercise(named name: String) -> Exercise {
        let muscles = Muscles(coreDataManager: coreDataManager)
        let measurementStyles = MeasurementStyles(coreDataManager: coreDataManager)
        let exerciseStyles = ExerciseStyles(coreDataManager: coreDataManager)
        return coreDataManager.getExercise(named: name) ??  coreDataManager.makeExercise(withName: name, exerciseStyle: exerciseStyles.normal, muscles: [muscles.chest], measurementStyle: measurementStyles.sets)
    }
}

/// Easily accessible for quickly seeding before generating snapshots .etc
final class ExerciseStyles {
    
    let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    // Computed Properties
    
    var assisted: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "ASSISTED")
    }
    
    var declined: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "DECLINED")
    }
    
    var explosive: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "EXPLOSIVE")
    }
    
    var inclined: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "INCLINED")
    }
    
    var inverted: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "INVERTED")
    }
    
    var normal: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "NORMAL")
    }
    
    var slow: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "SLOW")
    }
    
    var weighted: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "WEIGHTED")
    }
    
    // Methods
    
    private func getOrMakeExerciseStyle(named name: String) -> ExerciseStyle {
        return coreDataManager.getExerciseStyle(named: name) ?? coreDataManager.makeExerciseStyle(named: name)
    }
}

/// Easily accessible for quickly seeding before generating snapshots .etc
final class WorkoutStyles {
    
    let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    // Computed Properties
    
    var cardio: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "CARDIO")
    }
    
    var dropSet: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "DROPSET")
    }
    
    var fun: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "FUN")
    }
    
    var normal: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "NORMAL")
    }
    
    var other: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "OTHER")
    }
    
    var superSet: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "SUPERSET")
    }
    
    var technique: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "TECHNIQUE")
    }
    
    var weighted: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "WEIGHTED")
    }
    
    // Methods
    
    private func getOrMakeWorkoutStyle(named name: String) -> WorkoutStyle {
        return coreDataManager.getWorkoutStyle(named: name) ?? coreDataManager.makeWorkoutStyle(named: name)
    }
}

/// Easily accessible for quickly seeding before generating snapshots .etc
final class Muscles {
    
    let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    // Computed Properties
    
    var back: Muscle {
        return getOrMakeMuscle(named: "BACK")
    }
    
    var legs: Muscle {
        return getOrMakeMuscle(named: "LEGS")
    }
    
    var other: Muscle {
        return getOrMakeMuscle(named: "OTHER")
    }
    
    var glutes: Muscle {
        return getOrMakeMuscle(named: "GLUTES")
    }
    
    var shoulders: Muscle {
        return getOrMakeMuscle(named: "SHOULDERS")
    }
    
    var core: Muscle {
        return getOrMakeMuscle(named: "CORE")
    }
    
    var chest: Muscle {
        return getOrMakeMuscle(named: "CHEST")
    }
    
    var biceps: Muscle {
        return getOrMakeMuscle(named: "BICEPS")
    }
    
    var triceps: Muscle {
        return getOrMakeMuscle(named: "TRICEPS")
    }
    
    var cardio: Muscle {
        return getOrMakeMuscle(named: "CARDIO")
    }
    
    private func getOrMakeMuscle(named name: String) -> Muscle {
        return coreDataManager.getMuscle(named: name) ?? coreDataManager.makeMuscle(named: name)
    }
}
