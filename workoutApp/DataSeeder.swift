//
//  DataSeeder.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 25/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData

/*
 Used to make some example workouts, exercises, and exerciseLogs when the app is freshly installed
 */

final class DataSeeder {
    
    // MARK: Properties
    
    private let context: NSManagedObjectContext
    
    // Properties for seeding to Core Data
    private let seedMuscles = ["BICEPS", "TRICEPS", "GLUTES", "CORE", "CHEST", "SHOULDERS", "BACK", "QUADS", "OTHER"]
    private let seedWorkoutStyles = ["NORMAL", "WEIGHTED", "IMPROV"]
    private let seedExerciseStyles = ["NORMAL", "ASSISTED", "WEIGHTED"]
    private let seedMeasurementStyles = ["TIME", "SETS", "WEIGHTED SETS"] // Add countdown
    private let seedSkills = ["MUSCLE UP", "ZWIFT", "HANDSTAND", "PULL OVER", "L-SIT", "1H PUSH UP"]
    
    // MARK: - Initializer
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Methods
    
    public func seedCoreData() {
        seedWithExampleMuscleGroups()
        seedWithExampleSkillGroups()
        seedWithExampleWorkoutStyles()
        seedWithExampleExerciseStyles()
        seedWithExampleMeasurementStyles()
        seedWithExampleWarning()
        DatabaseFacade.saveContext()
    }
    
    /// Clears out persistent store to make room for snapshottable exercises only
    public func seedCoreDataForFastlaneSnapshots() {
        
        // Clear core data
        DataSeeder.clear(entity: Entity.WorkoutLog)
        DataSeeder.clear(entity: Entity.Exercise)
        DataSeeder.clear(entity: Entity.Workout)
        DataSeeder.clear(entity: Entity.Goal)
        
        DataSeeder.resetCounts() //
        
        // Generate exercises
        DatabaseFacade.makeExercise(withName: "SEED FLEXERS", exerciseStyle: ExerciseStyles.normal, muscles: [Muscles.biceps], skills: [Skill](), measurementStyle: MeasurementStyles.sets)
        
        // Generate workouts
        DatabaseFacade.makeWorkout(withName: "BOOTYBUILDER", workoutStyle: WorkoutStyles.normal, muscles: [Muscles.glutes], skills: [Skill](), exercises: [Exercises.bicepFlex])
        DatabaseFacade.makeWorkout(withName: "HARD CORE", workoutStyle: WorkoutStyles.normal, muscles: [Muscles.core], exercises: [Exercises.pullUp])
        DatabaseFacade.makeWorkout(withName: "MUSCLE UP", workoutStyle: WorkoutStyles.technique, muscles: [Muscles.back], exercises: [Exercises.pullUp])
        
        // Generate weighted workout
        let exercisesForPullDay: [Exercise] = [
            DatabaseFacade.makeExercise(withName: "WEIGHTED PULL UP", exerciseStyle: ExerciseStyles.weighted, muscles: [Muscles.back], skills: [Skill](), measurementStyle: MeasurementStyles.weightedSets),
            DatabaseFacade.makeExercise(withName: "PULL UP", exerciseStyle: ExerciseStyles.explosive, muscles: [Muscles.back], skills: [Skill](), measurementStyle: MeasurementStyles.sets),
            DatabaseFacade.makeExercise(withName: "AUSTRALIAN PULL UP", exerciseStyle: ExerciseStyles.weighted, muscles: [Muscles.back], skills: [Skill](), measurementStyle: MeasurementStyles.sets),
        ]
        DatabaseFacade.makeWorkout(withName: "PULL DAY", workoutStyle: WorkoutStyles.normal, muscles: [Muscles.back], exercises: exercisesForPullDay)
        
        // Goals
        DatabaseFacade.makeGoal("Live your dream")
        DatabaseFacade.makeGoal("Become extreme")
        
        DatabaseFacade.saveContext()
    }
    
    /// If any new Muscles/Styles are added in code, for example in an update -> seed to core data
    public func update() {
      
        // Muscles
        for muscleName in seedMuscles {
            if DatabaseFacade.getMuscle(named: muscleName.uppercased()) == nil {
                print("didnt exist so making muscle named \(muscleName)")
                makeMuscle(withName: muscleName.uppercased())
            }
        }
        
        // Workout Styles
        for workoutStyleName in seedWorkoutStyles {
            if DatabaseFacade.getWorkoutStyle(named: workoutStyleName) == nil {
                print("didnt exist so making workoutstyle named \(workoutStyleName)")
                makeWorkoutStyle(withName: workoutStyleName)
            }
        }
        
        // Exercise Styles
        for exerciseStyleName in seedExerciseStyles {
            if DatabaseFacade.getExerciseStyle(named: exerciseStyleName) == nil {
                print("didnt exist so making exercise named \(exerciseStyleName)")
                makeExerciseStyle(withName: exerciseStyleName)
            }
        }
        
        // Measurement Styles
        for measurementStyle in seedMeasurementStyles {
            if DatabaseFacade.getMeasurementStyle(named: measurementStyle) == nil {
                print("didnt exist so making measurementStyle named \(measurementStyle)")
                makeMeasurementStyle(withName: measurementStyle)
            }
        }
    }
    
    // MARK: - Seed Skills with Exercises
    
    public func seedSkillsWithExercises() {
        // First, make sure all skills exist
        seedWithExampleSkillGroups()
        
        // Define exercises for each skill
        let muscleUpExercises = [
            (name: "TRUNK SLAMMERS", style: ExerciseStyles.normal, muscles: [Muscles.back, Muscles.biceps], measurement: MeasurementStyles.time),
            (name: "EXPLOSIVE PULL UPS", style: ExerciseStyles.normal, muscles: [Muscles.back, Muscles.biceps], measurement: MeasurementStyles.time),
            (name: "STRAIGHT BAR DIPS", style: ExerciseStyles.normal, muscles: [Muscles.back, Muscles.triceps], measurement: MeasurementStyles.time),
            (name: "TRANSITION PRACTICE", style: ExerciseStyles.normal, muscles: [Muscles.shoulders, Muscles.chest], measurement: MeasurementStyles.sets),
            (name: "NEGATIVE MUSCLE UP", style: ExerciseStyles.slow, muscles: [Muscles.back, Muscles.biceps, Muscles.chest], measurement: MeasurementStyles.sets),
            (name: "BANDED MUSCLE UP", style: ExerciseStyles.assisted, muscles: [Muscles.back, Muscles.biceps, Muscles.chest], measurement: MeasurementStyles.sets)
        ]
        
        let handstandExercises = [
            (name: "WALL HANDSTAND", style: ExerciseStyles.normal, muscles: [Muscles.shoulders, Muscles.core], measurement: MeasurementStyles.time),
            (name: "HANDSTAND HOLDS", style: ExerciseStyles.normal, muscles: [Muscles.shoulders, Muscles.core], measurement: MeasurementStyles.time),
            (name: "HANDSTAND PUSH-UP", style: ExerciseStyles.normal, muscles: [Muscles.shoulders, Muscles.triceps], measurement: MeasurementStyles.sets),
            (name: "PIKE PUSHUPS", style: ExerciseStyles.normal, muscles: [Muscles.shoulders, Muscles.core], measurement: MeasurementStyles.time),
            (name: "HAND STRENGTHENERS", style: ExerciseStyles.normal, muscles: [Muscles.shoulders, Muscles.core], measurement: MeasurementStyles.time)
        ]
        
        let lsitToHandstandExercises = [
            (name: "TUCKED L-SIT", style: ExerciseStyles.normal, muscles: [Muscles.core, Muscles.shoulders], measurement: MeasurementStyles.time),
            (name: "ONE LEG L-SIT", style: ExerciseStyles.normal, muscles: [Muscles.core, Muscles.shoulders], measurement: MeasurementStyles.time),
            (name: "FULL L-SIT", style: ExerciseStyles.normal, muscles: [Muscles.core, Muscles.shoulders], measurement: MeasurementStyles.time),
            (name: "FOLDERS", style: ExerciseStyles.normal, muscles: [Muscles.core, Muscles.shoulders], measurement: MeasurementStyles.time)
        ]
        
        let pullOverExercises = [
            (name: "BAR POUNDERS", style: ExerciseStyles.slow, muscles: [Muscles.back, Muscles.core], measurement: MeasurementStyles.sets),
            (name: "UPSIDE DOWN ROWS", style: ExerciseStyles.normal, muscles: [Muscles.back, Muscles.core], measurement: MeasurementStyles.sets)
        ]
        
        let oneHandPushUpExercises = [
            (name: "PUSH UP", style: ExerciseStyles.normal, muscles: [Muscles.chest, Muscles.triceps], measurement: MeasurementStyles.sets),
            (name: "INCLINED PUSH UP", style: ExerciseStyles.normal, muscles: [Muscles.chest, Muscles.triceps], measurement: MeasurementStyles.sets),
            (name: "ARCHER PUSH UP", style: ExerciseStyles.normal, muscles: [Muscles.chest, Muscles.triceps], measurement: MeasurementStyles.sets),
            (name: "PARTIAL 1H PUSH UP", style: ExerciseStyles.normal, muscles: [Muscles.chest, Muscles.triceps], measurement: MeasurementStyles.sets),
            (name: "FULL 1H PUSH UP", style: ExerciseStyles.normal, muscles: [Muscles.chest, Muscles.triceps], measurement: MeasurementStyles.sets)
        ]
        
        let bikeExercises = [
            (name: "Pistol Squats", style: ExerciseStyles.normal, muscles: [Muscles.legs], measurement: MeasurementStyles.sets),
            (name: "Lunges", style: ExerciseStyles.normal, muscles: [Muscles.legs], measurement: MeasurementStyles.sets),
            (name: "Box steps", style: ExerciseStyles.normal, muscles: [Muscles.legs], measurement: MeasurementStyles.sets),
            (name: "Box jump", style: ExerciseStyles.normal, muscles: [Muscles.legs], measurement: MeasurementStyles.sets),
            (name: "Extreme jump", style: ExerciseStyles.normal, muscles: [Muscles.legs], measurement: MeasurementStyles.sets),
        ]
        
        // Associate exercises with skills
        associateExercisesWithSkill(skillName: "MUSCLE UP", exercises: muscleUpExercises)
        associateExercisesWithSkill(skillName: "HANDSTAND", exercises: handstandExercises)
        associateExercisesWithSkill(skillName: "L-SIT TO HANDSTAND", exercises: lsitToHandstandExercises)
        associateExercisesWithSkill(skillName: "PULL OVER", exercises: pullOverExercises)
        associateExercisesWithSkill(skillName: "1H PUSH UP", exercises: oneHandPushUpExercises)
        associateExercisesWithSkill(skillName: "ZWIFT", exercises: bikeExercises)

        DatabaseFacade.saveContext()
        
        // Print the created exercises for verification
        printSkillsWithExercises()
    }
    
    // Helper method to associate exercises with a skill
    private func associateExercisesWithSkill(
        skillName: String,
        exercises: [(name: String, style: ExerciseStyle, muscles: [Muscle], measurement: MeasurementStyle)]
    ) {
        // Get or create the skill
        guard let skill = DatabaseFacade.getSkill(named: skillName.uppercased()) else {
            print("Error: Skill \(skillName) not found")
            return
        }
        
        // Create exercises and associate them with the skill
        for exerciseInfo in exercises {
            // Check if exercise already exists
            if let existingExercise = DatabaseFacade.getExercise(named: exerciseInfo.name.uppercased()) {
                // Add the skill to the existing exercise
                existingExercise.addToSkillsUsed(skill)
                skill.addToUsedInExercises(existingExercise)
            } else {
                // Create a new exercise
                let newExercise = DatabaseFacade.makeExercise(
                    withName: exerciseInfo.name.uppercased(),
                    exerciseStyle: exerciseInfo.style,
                    muscles: exerciseInfo.muscles,
                    skills: [skill],
                    measurementStyle: exerciseInfo.measurement
                )
                
                // Explicitly set the relationship
                skill.addToUsedInExercises(newExercise)
            }
        }
    }
    
    // MARK: - Seed Methods
    
    private func seedWithExampleMuscleGroups() {
        for muscle in seedMuscles {
            if DatabaseFacade.getMuscle(named: muscle) == nil {
                makeMuscle(withName: muscle.uppercased())
            }
        }
    }
    
    private func seedWithExampleSkillGroups() {
        print("seeding skills")
        for skill in seedSkills {
            if DatabaseFacade.getSkill(named: skill) == nil {
                makeSkill(withName: skill.uppercased())
            }
        }
    }
    
    private func seedWithExampleWarning() {
        makeWarning(withMessage: "Welcome to the workout app")
    }
    
    private func seedWithExampleWorkoutStyles() {
        for name in seedWorkoutStyles {
            makeWorkoutStyle(withName: name)
        }
        printWorkoutStyles()
    }
    
    private func seedWithExampleExerciseStyles() {
        for exerciseStyleName in seedExerciseStyles {
            makeExerciseStyle(withName: exerciseStyleName)
        }
    }

    private func seedWithExampleMeasurementStyles() {
        for measurementStyleName in seedMeasurementStyles {
            makeMeasurementStyle(withName: measurementStyleName)
        }
    }
    
    //  MARK: - Maker methods

    private func makeMuscle(withName name: String) {
        let muscleRecord = DatabaseFacade.makeMuscle()
        muscleRecord.name = name.uppercased()
    }
    
    private func makeSkill(withName name: String) {
        let skillRecord = DatabaseFacade.makeSkill(named: name.uppercased())
    }
    
    private func makeWarning(withMessage message: String) {
        let warningRecord = DatabaseFacade.makeWarning()
        warningRecord.dateMade = Date() as Date
        warningRecord.message = message
    }
    
    private func makeWorkoutStyle(withName name: String) {
        guard DatabaseFacade.getWorkoutStyle(named: name.uppercased()) == nil else {
            return
        }
        let workoutStyleRecord = DatabaseFacade.makeWorkoutStyle()
        workoutStyleRecord.name = name.uppercased()
    }
    
    private func makeExerciseStyle(withName name: String) {
        guard DatabaseFacade.getExerciseStyle(named: name.uppercased()) == nil else {
            return
        }
        let exerciseStyleRecord = DatabaseFacade.makeExerciseStyle()
        exerciseStyleRecord.name = name.uppercased()
    }
    
    private func makeMeasurementStyle(withName name: String) {
        guard DatabaseFacade.getMeasurementStyle(named: name.uppercased()) == nil else {
            return
        }
        let measurementStyleRecord = DatabaseFacade.makeMeasurementStyle()
        measurementStyleRecord.name = name.uppercased()
    }
    
    // MARK: - Clear methods
    
    /// Completely removes all instances of a type from The persistence store
    static func clear(entity: Entity) {
        
        // Create the delete request for the specified entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        // Get reference to the persistent container
        let persistentContainer = DatabaseFacade.persistentContainer
        
        // Perform the delete
        do {
            try persistentContainer.viewContext.execute(deleteRequest)
        } catch let error as NSError {
            print(error)
        }
        
        DatabaseFacade.saveContext()
    }
    
    /// Method resets static counts of design and performances, and is needed batchDelete does not run NSManagedObject.prepareForDelete() on each individual object
    static func resetCounts() {
        for workoutStyle in DatabaseFacade.fetchWorkoutStyles() {
            workoutStyle.resetCount()
        }
    }
    
    // MARK: - Print methods
    
    private func printWorkouts() {

        do {
            let request = NSFetchRequest<Workout>(entityName: Entity.Workout.rawValue)
            let allWorkouts = try context.fetch(request)
            
            print("workout count: ", allWorkouts.count)
            
            for workout in allWorkouts {
                print("\nName: ", workout.name ?? "")
                print("----------------------")
                
                if let exercises = workout.exercises?.array as? [Exercise] {
                    for exercise in exercises {
                        print(" - \(exercise.name ?? "fail")")
                    }
                }
            }
        } catch {
                print("error in printing workouts")
        }
    }
    
    private func printMuscles() {
        do {
            let request = NSFetchRequest<Muscle>(entityName: Entity.Muscle.rawValue)
            let allMuscles = try context.fetch(request)
            
            print("Muscle count: ", allMuscles.count)
            print()
            
            for muscle in allMuscles {
                print("Name: ", muscle.name ?? "")
            }
            print("----------------------")
        } catch {
            print("error in printing Muscles")
        }
    }
    
    private func printWorkoutStyles() {
        do {
            let request = NSFetchRequest<WorkoutStyle>(entityName: Entity.WorkoutStyle.rawValue)
            let allWorkoutStyles = try context.fetch(request)

            print("WorkoutStyle count: ", allWorkoutStyles.count)
            for style in allWorkoutStyles {
                print("Name: ", style.name ?? "")
            }
        } catch {
            print("error in printing workoutStyles")
        }
    }
    
    private func printExercises() {
        do {
            let request = NSFetchRequest<Exercise>(entityName: Entity.Exercise.rawValue)
            let allExercises = try context.fetch(request)
            
            print("Exercise count: ", allExercises.count)
            for exercise in allExercises {
                print()
                print("Name: ", exercise.name ?? "")
                print("Muscle: ", exercise.getMuscles().map({ return $0.name
                }))
                print("Type: ", exercise.style?.name ?? "")
                
                // Print associated skills
                if let skills = exercise.skillsUsed?.allObjects as? [Skill], !skills.isEmpty {
                    print("Skills: ", skills.map({ return $0.name ?? "unknown" }))
                }
            }
        } catch {
            print("error in printing exercises")
        }
    }
    
    private func printSkillsWithExercises() {
        do {
            let request = NSFetchRequest<Skill>(entityName: Entity.Skill.rawValue)
            let allSkills = try context.fetch(request)
            
            print("Skill count: ", allSkills.count)
            for skill in allSkills {
                print()
                print("Skill: ", skill.name ?? "")
                print("----------------------")
                
                if let exercises = skill.usedInExercises?.allObjects as? [Exercise], !exercises.isEmpty {
                    for exercise in exercises {
                        print(" - \(exercise.name ?? "unknown")")
                    }
                } else {
                    print(" No exercises associated with this skill")
                }
            }
        } catch {
            print("error in printing skills with exercises")
        }
    }
    
    // MARK: - Exercise Helper Methods
    
    private func randomRepNumber() -> Int16 {
        let result = Int16(arc4random_uniform(UInt32(99)))
        return result
    }
    
    private func randomDate(daysBack: Int)-> NSDate? {
        let day = arc4random_uniform(UInt32(daysBack))+1
        let hour = arc4random_uniform(UInt32(23))
        let minute = arc4random_uniform(UInt32(59))
        
        let today = Date(timeIntervalSinceNow: 0)
        let gregorian  = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        var offsetComponents = DateComponents()
        offsetComponents.day = Int(day - 1)
        offsetComponents.hour = Int(hour)
        offsetComponents.minute = Int(minute)
        
        let randomDate = gregorian?.date(byAdding: offsetComponents, to: today, options: .init(rawValue: 0) )
        return randomDate as NSDate?
    }
}

fileprivate final class MeasurementStyles {
    
    // Computed Properties
    
    static var sets: MeasurementStyle {
        return getOrMakeMeasurementStyle(named: "SETS")
    }
    
    // time
    static var time: MeasurementStyle {
        return getOrMakeMeasurementStyle(named: "TIME")
    }
    
    // weighted sets
    static var weightedSets: MeasurementStyle {
        return getOrMakeMeasurementStyle(named: "WEIGHTED SETS")
    }
    
    // Methods
    private static func getOrMakeMeasurementStyle(named name: String) -> MeasurementStyle {
        return DatabaseFacade.getMeasurementStyle(named: name) ?? DatabaseFacade.makeMeasurementStyle(named: name)
    }
}

fileprivate final class Exercises {
    
    // Computed Properties
    
    static var pullUp: Exercise {
        return getOrMakeExercise(named: "PULL UP")
    }
    
    static var bicepFlex: Exercise {
        return getOrMakeExercise(named: "BICEP FLEX")
    }
    
    // Methods
    
    private static func getOrMakeExercise(named name: String) -> Exercise {
        return DatabaseFacade.getExercise(named: name) ??  DatabaseFacade.makeExercise(withName: name, exerciseStyle: ExerciseStyles.normal, muscles: [Muscles.chest], skills: [Skill](), measurementStyle: MeasurementStyles.sets)
    }
}

fileprivate final class ExerciseStyles {
    
    // Computed Properties
    
    static var assisted: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "ASSISTED")
    }
    
    static var declined: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "DECLINED")
    }
    
    static var explosive: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "EXPLOSIVE")
    }
    
    static var inclined: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "INCLINED")
    }
    
    static var inverted: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "INVERTED")
    }
    
    static var normal: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "NORMAL")
    }
    
    static var slow: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "SLOW")
    }
    
    static var weighted: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "WEIGHTED")
    }
    
    // Methods
    
    private static func getOrMakeExerciseStyle(named name: String) -> ExerciseStyle {
        return DatabaseFacade.getExerciseStyle(named: name) ?? DatabaseFacade.makeExerciseStyle(named: name)
    }
}

/// Used to easily make or get workoutstyles when seeding
fileprivate final class WorkoutStyles {
    
    // Computed Properties
    
    static var cardio: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "CARDIO")
    }
    
    static var improv: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "IMPROV")
    }
    
    static var dropSet: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "DROPSET")
    }
    
    static var fun: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "FUN")
    }
    
    static var normal: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "NORMAL")
    }
    
    static var other: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "OTHER")
    }
    
    static var superSet: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "SUPERSET")
    }
    
    static var technique: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "TECHNIQUE")
    }
    
    static var weighted: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "WEIGHTED")
    }
    
    // Methods
    
    private static func getOrMakeWorkoutStyle(named name: String) -> WorkoutStyle {
        return DatabaseFacade.getWorkoutStyle(named: name) ?? DatabaseFacade.makeWorkoutStyle(named: name)
    }
}

/// Easily accessible muscles for quickly seeding before generating snapshots .etc
fileprivate final class Muscles {
    
    // Computed Properties
    
    static var back: Muscle {
        return getOrMakeMuscle(named: "BACK")
    }
    
    static var legs: Muscle {
        return getOrMakeMuscle(named: "LEGS")
    }
    
    static var other: Muscle {
        return getOrMakeMuscle(named: "OTHER")
    }
    
    static var glutes: Muscle {
        return getOrMakeMuscle(named: "GLUTES")
    }
    
    static var shoulders: Muscle {
        return getOrMakeMuscle(named: "SHOULDERS")
    }
    
    static var core: Muscle {
        return getOrMakeMuscle(named: "CORE")
    }
    
    static var chest: Muscle {
        return getOrMakeMuscle(named: "CHEST")
    }
    
    static var biceps: Muscle {
        return getOrMakeMuscle(named: "BICEPS")
    }
    
    static var triceps: Muscle {
        return getOrMakeMuscle(named: "TRICEPS")
    }
    
    static var cardio: Muscle {
        return getOrMakeMuscle(named: "CARDIO")
    }
    
    private static func getOrMakeMuscle(named name: String) -> Muscle {
        return DatabaseFacade.getMuscle(named: name) ?? DatabaseFacade.makeMuscle(named: name)
    }
}

/// Easily accessible skills for quickly seeding before generating snapshots etc.
fileprivate final class Skills {
    
    // Computed Properties
    
    static var muscleUp: Skill {
        return getOrMakeSkill(named: "MUSCLE UP")
    }
    
    static var handstand: Skill {
        return getOrMakeSkill(named: "HANDSTAND")
    }
    
    static var pullOver: Skill {
        return getOrMakeSkill(named: "PULL OVER")
    }
    
    static var lSit: Skill {
        return getOrMakeSkill(named: "L-SIT")
    }
    
    static var oneHandPushUp: Skill {
        return getOrMakeSkill(named: "1H PUSH UP")
    }
    
    static var other: Skill {
        return getOrMakeSkill(named: "OTHER")
    }
    
    // Methods
    
    private static func getOrMakeSkill(named name: String) -> Skill {
        return DatabaseFacade.getSkill(named: name) ?? DatabaseFacade.makeSkill(named: name)
    }
}
