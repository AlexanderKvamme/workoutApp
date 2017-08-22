//
//  pickableEntity.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 21/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

@objc protocol pickableEntity {
    @objc var name: String? { get set }
}

// Extend entities

extension MeasurementStyle: pickableEntity {}
extension ExerciseStyle: pickableEntity {}
extension Muscle: pickableEntity {}
extension WorkoutStyle: pickableEntity {}
extension Exercise: pickableEntity {}
