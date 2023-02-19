//
//  WorkoutMock.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 19/02/2023.
//  Copyright © 2023 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData


public struct Mock {
    
    public static var workout: Workout {
        let test = DatabaseFacade.makeWorkout(withName: "Mock Workout",
                                                 workoutStyle: Mock.workoutStyle,
                                                 muscles: Mock.muscles,
                                                 exercises: Mock.exercises)
        return test
    }
    
    public static var exercise: Exercise {
       return DatabaseFacade.makeExercise(withName: "Mock exercise 1",
                                            exerciseStyle: Mock.exerciseStyle,
                                            muscles: Mock.muscles,
                                            measurementStyle: Mock.measurementStyle)
    }
    
    public static var exerciseStyle: ExerciseStyle {
        let es = DatabaseFacade.makeExerciseStyle(named: "Mockify")
        return es
    }

    public static var muscles: [Muscle] {
        let muscle = DatabaseFacade.makeMuscle(named: "Mock muscle")
        return [muscle]
    }
    
    public static var measurementStyle: MeasurementStyle {
        return DatabaseFacade.makeMeasurementStyle(named: "Mock measurement style")
    }
    
    public static var workoutStyle: WorkoutStyle {
        return DatabaseFacade.makeWorkoutStyle(named: "Mock style")
    }
    
    public static var exercises: [Exercise] {
        return [DatabaseFacade.makeExercise(withName: "Mock exercice A",
                                            exerciseStyle: Mock.exerciseStyle,
                                            muscles: Mock.muscles,
                                            measurementStyle: Mock.measurementStyle)]
    }
}


