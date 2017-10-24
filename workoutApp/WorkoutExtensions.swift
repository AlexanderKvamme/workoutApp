//
//  WorkoutExtensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 16/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

extension Workout {
    
    // MARK: Getters
    
    func getExercises(includeRetired: Bool) -> [Exercise] {
        
        var exercises = [Exercise]()
        
        if let e = self.exercises {
            let exercisesAsArray = e.array as! [Exercise]
            exercises = exercisesAsArray.filter({ (exercise) -> Bool in
                exercise.isRetired == includeRetired
            })
        }
        return exercises
    }
    
    func getMuscles() -> [Muscle] {
        
        guard let muscles = self.musclesUsed else {
            fatalError()
        }
        
        return Array(muscles) as! [Muscle]
    }
    
    // MARK: Setters
    
    @nonobjc func setName(_ newName: String) {
        self.name = newName
    }
    
    func setStyle(_ style: WorkoutStyle) {
        self.workoutStyle = style
    }
    
    func setMuscles(_ muscles: [Muscle]) {
        
        // FIXME: - not working frmo exerciseEditor
        print("tryna set muscles")

        for muscle in muscles {
            self.addToMusclesUsed(muscle)
        }
    }
    
    @nonobjc func setExercises(_ exercises: [Exercise]) {
        self.exercises = NSOrderedSet(array: exercises)
    }
    
    /// Returnes a string reprenseting time since last performance, in the style of "1D"/"2W" .etc or "NA" if never before performed
    func timeSinceLastPerformence() -> String {
        
        guard let timeOfLatestPerformence = self.latestPerformence?.dateEnded else {
            return "NA"
        }
        
        let timeIntervalSinceWorkout = Date().timeIntervalSince(timeOfLatestPerformence as Date)
        let shortenedString = timeIntervalSinceWorkout.asMinimalString()
        return shortenedString
    }
    
    func addPerformance(_ workoutLog: WorkoutLog) {
        self.performanceCount += 1
    
        if let end = workoutLog.dateEnded, let start = workoutLog.dateStarted {
        let elapsedTime = end.timeIntervalSince(start as Date)
            self.totalTimeSpent += elapsedTime
        }
    }
    
    func getAverageTime() -> String {
        let average = totalTimeSpent/Double(performanceCount)
        
        return average.asMinimalString()
    }
}

