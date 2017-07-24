//
//  ExerciseDataSource.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/*
 Data source for the exercise table view used to display all exercises assosciated with a workout. So you tap a workout, and you enter a tableview with all exercises owned by that workout. This is the datasource that provides these items.
 */

class ExerciseTableViewDataSource: NSObject, UITableViewDataSource {
    
    let cellIdentifier: String = "exerciseCell"
    var currentExercises: [Exercise]!
    weak var owner: ExerciseTableViewController!
    
    // MARK: - Initializers
    
    init(workout: Workout) {
        super.init()
        
        if let exercisesFromWorkout = workout.exercises {
            currentExercises = exercisesFromWorkout.map({return $0 as! Exercise})
        } else {
            currentExercises = [Exercise]()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentExercises.count // uses sections instead of rows to space out cells easily
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exercise = currentExercises[indexPath.section]
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ExerciseTableViewCell
        cell = ExerciseTableViewCell(withExercise: exercise, andIdentifier: cellIdentifier)
        cell.owner = owner
        
        if let name = exercise.name {
            cell.box.setTitle(name)

        }
//        cell.layoutIfNeeded()
        return cell
    }
}

