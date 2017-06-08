//
//  PickerProtocols.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 07/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

/*
    protocol to allow selecting type/muscle in a separate VC pushed onto the nav stack.
 
    with isStringSender and isStringReceiver, you can send back a selected value and update the selection in the presenting VC.
 */

protocol isStringSender {
    func sendStringBack(_ string: String)
}

protocol isStringReceiver {
    var receiveHandler: ((String) -> Void) { get set }
}

extension isStringReceiver {
    func receive(_ string: String){
        receiveHandler(string)
    }
}
