//
//  Picker protocols.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 25/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

// MARK: Pickable Sender

protocol PickableSender: class {
    associatedtype Pickable
    
    func sendBack(pickable: Pickable) -> Void
    var pickableReceiver: PickableReceiver? { get set }
}

// MARK: Pickable Receiver

protocol PickableReceiver: class {
    func receive(pickable: PickableEntity)
}

