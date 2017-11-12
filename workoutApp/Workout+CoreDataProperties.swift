//
//  Workout+CoreDataProperties.swift
//  
//
//  Created by Alexander Kvamme on 08/11/2017.
//
//

import Foundation
import CoreData


extension Workout {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workout> {
        return NSFetchRequest<Workout>(entityName: "Workout")
    }

    @NSManaged public var name: String?
    @NSManaged private(set) var isRetired: Bool
    @NSManaged private(set) var performanceCount: Int16
    @NSManaged public var totalTimeSpent: Double
    @NSManaged public var exercises: NSOrderedSet?
    @NSManaged public var latestPerformence: WorkoutLog?
    @NSManaged public var loggedWorkouts: NSSet?
    @NSManaged public var musclesUsed: NSSet?
    @NSManaged public var workoutStyle: WorkoutStyle?
    
}

// MARK: - isRetired methods

extension Workout {
    /// Public entrypoint to manage the isRetired property
    func makeRetired(_ bool: Bool) {
        // Delegate to appropriate method
        switch bool {
        case true:
            self.retire()
        case false:
            self.unretire()
        }
    }
    
    private func retire() {
        self.isRetired = true
        self.getWorkoutStyle().decrementWorkoutDesignCount()
    }
    
    private func unretire() {
        self.isRetired = false
        self.getWorkoutStyle().incrementWorkoutDesignCount()
    }
}

// MARK: - Deletion

extension Workout {

    override public func prepareForDeletion() {
        getWorkoutStyle().removeFromUsedInWorkouts(self)
        getWorkoutStyle().decrementWorkoutDesignCount()
    }
}

// MARK: - Incrementers

extension Workout {
    // MARK: Increments Log Count
    
    func incrementPerformanceCount() {
        self.performanceCount += 1
    }
    
    func incrementPerformanceCount(by amount: Int) {
        self.performanceCount += Int16(amount)
    }
    
    // MARK: Decrement Log Count
    
    func decrementPerformanceCount(by amount: Int) {
        self.performanceCount -= Int16(amount)
    }
    
    func decrementPerformanceCount() {
        self.performanceCount -= 1
    }
}


// MARK: Generated accessors for exercises
extension Workout {

    @objc(insertObject:inExercisesAtIndex:)
    @NSManaged public func insertIntoExercises(_ value: Exercise, at idx: Int)

    @objc(removeObjectFromExercisesAtIndex:)
    @NSManaged public func removeFromExercises(at idx: Int)

    @objc(insertExercises:atIndexes:)
    @NSManaged public func insertIntoExercises(_ values: [Exercise], at indexes: NSIndexSet)

    @objc(removeExercisesAtIndexes:)
    @NSManaged public func removeFromExercises(at indexes: NSIndexSet)

    @objc(replaceObjectInExercisesAtIndex:withObject:)
    @NSManaged public func replaceExercises(at idx: Int, with value: Exercise)

    @objc(replaceExercisesAtIndexes:withExercises:)
    @NSManaged public func replaceExercises(at indexes: NSIndexSet, with values: [Exercise])

    @objc(addExercisesObject:)
    @NSManaged public func addToExercises(_ value: Exercise)

    @objc(removeExercisesObject:)
    @NSManaged public func removeFromExercises(_ value: Exercise)

    @objc(addExercises:)
    @NSManaged public func addToExercises(_ values: NSOrderedSet)

    @objc(removeExercises:)
    @NSManaged public func removeFromExercises(_ values: NSOrderedSet)

}

// MARK: Generated accessors for loggedWorkouts
extension Workout {

    @objc(addLoggedWorkoutsObject:)
    @NSManaged public func addToLoggedWorkouts(_ value: WorkoutLog)

    @objc(removeLoggedWorkoutsObject:)
    @NSManaged public func removeFromLoggedWorkouts(_ value: WorkoutLog)

    @objc(addLoggedWorkouts:)
    @NSManaged public func addToLoggedWorkouts(_ values: NSSet)

    @objc(removeLoggedWorkouts:)
    @NSManaged public func removeFromLoggedWorkouts(_ values: NSSet)

}

// MARK: Generated accessors for musclesUsed
extension Workout {

    @objc(addMusclesUsedObject:)
    @NSManaged public func addToMusclesUsed(_ value: Muscle)

    @objc(removeMusclesUsedObject:)
    @NSManaged public func removeFromMusclesUsed(_ value: Muscle)

    @objc(addMusclesUsed:)
    @NSManaged public func addToMusclesUsed(_ values: NSSet)

    @objc(removeMusclesUsed:)
    @NSManaged public func removeFromMusclesUsed(_ values: NSSet)

}
