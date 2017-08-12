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

protocol isStringSender {
    func sendStringBack(_ string: String)
}

protocol isStringReceiver: class {
    var receiveHandler: ((String) -> Void) { get set }
}

extension isStringReceiver {
    func receive(_ string: String){
        receiveHandler(string)
    }
}
