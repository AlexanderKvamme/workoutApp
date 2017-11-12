//
//  File.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SwipeCellKit


protocol isBoxTableViewDataSource: class, UITableViewDataSource {
    
    var cellIdentifier: String { get set }
    weak var owner: SwipeTableViewCellDelegate? { get set }
    
    func refresh()
    func getData() -> [NSManagedObject]?
    func deleteDataAt(_ indexPath: IndexPath)   
}

protocol isWorkoutTableViewDataSource: isBoxTableViewDataSource {
    func getWorkout(at indexPath: IndexPath) -> Workout
}

extension isWorkoutTableViewDataSource {
    func getDataCount() -> Int {
        return getData()?.count ?? 0
    }
}
