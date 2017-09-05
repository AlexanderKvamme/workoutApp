//
//  DefaultsFacade.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

// Enums: - Enums related to User Defaults

enum DefaultKeys {
    static let unitOfMeasurement = "Unit of Measurement"
    static let weightIncrements = "Weight Increment Amount"
    static let userDefaultsHasBeenSeeded = "UserDefaultsHasBeenSeeded"
}

// MARK: - Model of Defaults

struct UserPreferenceHolder {
    
    private init() {}
    
    static var preferences: [UserPreference] = {[
        UserPreference(preferenceName: DefaultKeys.unitOfMeasurement, choices: ["KG", "LBS"]),
        UserPreference(preferenceName: DefaultKeys.weightIncrements, choices: ["0.25", "0.5", "1"])
    ]}()
}

struct UserPreference {
    
    let preferenceName: String
    let choices: [String]
    
    init(preferenceName: String, choices: [String]) {
        self.preferenceName = preferenceName
        self.choices = choices
    }
}

// MARK: Class

final class UserDefaultsFacade {
    
    // MARK: - Properties
    
    static var hasInitialDefaults: Bool {
        return UserDefaults.standard.bool(forKey: DefaultKeys.userDefaultsHasBeenSeeded)
    }
    
    // MARK: - Methods
    
    // MARK: API
    
    static func seed() {
        
        let defaultIncrement = "1"
        let defaultWeight = "KG"
        
        UserDefaults.standard.set(defaultIncrement, forKey: DefaultKeys.weightIncrements)
        UserDefaults.standard.set(defaultWeight, forKey: DefaultKeys.unitOfMeasurement)
        UserDefaults.standard.set(true, forKey: DefaultKeys.userDefaultsHasBeenSeeded)
    }
    
    static func getActiveSelection(for preference: UserPreference) -> String? {
        return UserDefaults.standard.value(forKey: preference.preferenceName) as? String
    }
    
    static func setSelection(forPreference preference: UserPreference, to str: String) {
        UserDefaults.standard.set(str, forKey: preference.preferenceName)
    }
}

