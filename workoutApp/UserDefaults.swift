//
//  Onboarding.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation


extension UserDefaults {
    static func isFirstLaunch() -> Bool {
        let launchedBefore = UserDefaults.standard.bool(forKey: "hasBeenLaunchedBefore")
        if !launchedBefore {
            UserDefaults.standard.set(true, forKey: "hasBeenLaunchedBefore")
        }
        return !launchedBefore
    }
}

