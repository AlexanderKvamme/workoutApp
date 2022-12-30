//
//  AKTimerStatus.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/12/2022.
//  Copyright © 2022 Alexander Kvamme. All rights reserved.
//

import UIKit

enum AKTimerStatus {
    case ticking(Int, Int) // current and target
    case inactive
    case done
}


protocol AKTimerDelegate {
    func statusDidChange(to status: AKTimerStatus)
}
