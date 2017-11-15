//
//  Globals.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 15/11/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

let globalKeyboard: Keyboard = {
    let screenWidth = Constant.UI.width
    let kb = Keyboard(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth))
    return kb
}()

