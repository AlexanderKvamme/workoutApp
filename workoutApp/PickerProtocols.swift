//
//  PickerProtocols.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 07/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

/*
    Protocol to allow selecting type/muscle in a separate VC pushed onto the nav stack. With isStringSender and isStringReceiver, you can send back a name of the selected value and update the selection in the presenting VC. This is done by storing a closure in the receiveHandler variable, and this is then called from the pickerView, along with a string argument.
 */


//MARK: - String receiver protocols
// Used to pass string values back from muscle/type/weight/time pickers

protocol isStringSender {
    func sendStringBack(_ string: String)
}

protocol isStringReceiver: class {
    var stringReceivedHandler: ((String) -> Void) { get set }
}

extension isStringReceiver {
    func receiveString(_ string: String){
        stringReceivedHandler(string)
    }
}

// MARK: - Exercise sender and receiver

// used to pass exercises to and from exercisePickersViewControllers from for example NewWorkoutController

protocol isExerciseSender {
    func sendExerciseBack(_ exercise: Exercise)
}

protocol isExerciseReceiver: class {
    var receiveExercises: (([Exercise]) -> ()) { get set }
}

extension isExerciseReceiver {
    func receive(_ exercises: [Exercise]){
        receiveExercises(exercises)
    }
}

