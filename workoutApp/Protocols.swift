//
//  Picker protocols.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 25/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation


// MARK: Sender

protocol PickableSender: class {
    associatedtype Pickable
    
    func sendBack(pickable: Pickable) -> Void
    weak var pickableReceiver: PickableReceiver? { get set }
}

// MARK: Receiver

protocol PickableReceiver: class {
    func receivePickable(_ : PickableEntity)
}









// MARK: ExerciseStyle sender/receiver protocols

protocol isExerciseStyleReceiver: class {
    func receiveExerciseStyle(_ :ExerciseStyle) -> Void
}

protocol isExerciseStyleSender {
    weak var exerciseStyleReceiverDelegate: isExerciseStyleReceiver? { get set }
    
    func sendExerciseStyleBack(_ :ExerciseStyle) -> Void
}
