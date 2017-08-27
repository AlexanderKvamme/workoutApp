//
//  pickableEntity.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 21/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

@objc protocol PickableEntity {
    @objc var name: String? { get set }
}

// Extend entities

extension MeasurementStyle: PickableEntity {}
extension ExerciseStyle: PickableEntity {}
extension Muscle: PickableEntity {}
extension WorkoutStyle: PickableEntity {}
extension Exercise: PickableEntity {}
