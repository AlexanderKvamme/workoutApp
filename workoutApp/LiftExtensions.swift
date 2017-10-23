//
//  LiftExtensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 19/10/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

extension Lift {
    func isWeighted() -> Bool {
        guard let owner = owner else {
            preconditionFailure("all lifts should have owner")
        }
        return owner.isWeighted()
    }
}
