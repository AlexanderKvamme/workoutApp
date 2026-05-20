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
    static let muscleLightGray = "Light Gray After"
    static let muscleGray = "Gray After"
    static let muscleDarkGray = "Dark Gray After"
    static let muscleBlack = "Black After"
}

// MARK: - Model of Defaults

struct UserPreferenceHolder {
    
    private init() {}
    
    static var preferences: [UserPreference] = {[
        UserPreference(preferenceName: DefaultKeys.unitOfMeasurement, choices: ["KG", "LBS"]),
        UserPreference(preferenceName: DefaultKeys.weightIncrements, choices: ["0.25", "0.5", "1"]),
        UserPreference(preferenceName: DefaultKeys.muscleLightGray, choices: ["1", "3", "5", "10"]),
        UserPreference(preferenceName: DefaultKeys.muscleGray,      choices: ["5", "10", "15", "25"]),
        UserPreference(preferenceName: DefaultKeys.muscleDarkGray,  choices: ["10", "20", "30", "50"]),
        UserPreference(preferenceName: DefaultKeys.muscleBlack,     choices: ["20", "35", "50", "100"]),
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
        UserDefaults.standard.set("1",   forKey: DefaultKeys.weightIncrements)
        UserDefaults.standard.set("KG",  forKey: DefaultKeys.unitOfMeasurement)
        UserDefaults.standard.set("1",   forKey: DefaultKeys.muscleLightGray)
        UserDefaults.standard.set("10",  forKey: DefaultKeys.muscleGray)
        UserDefaults.standard.set("25",  forKey: DefaultKeys.muscleDarkGray)
        UserDefaults.standard.set("50",  forKey: DefaultKeys.muscleBlack)
        UserDefaults.standard.set(true,  forKey: DefaultKeys.userDefaultsHasBeenSeeded)
    }

    static func muscleThreshold(for key: String, fallback: Int) -> Int {
        guard let str = UserDefaults.standard.string(forKey: key), let val = Int(str) else {
            return fallback
        }
        return val
    }
    
    static func getActiveSelection(for preference: UserPreference) -> String? {
        return UserDefaults.standard.value(forKey: preference.preferenceName) as? String
    }
    
    static func setSelection(forPreference preference: UserPreference, to str: String) {
        UserDefaults.standard.set(str, forKey: preference.preferenceName)
    }
}

