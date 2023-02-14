//
//  AKTimer.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/12/2022.
//  Copyright © 2022 Alexander Kvamme. All rights reserved.
//

import Foundation


class AKTimer {
    var startDate = Date()
    var timer: Timer?
    var delegate: AKTimerDelegate?
    var status: AKTimerStatus = .inactive {
        didSet {
            propegateStatusChange()
        }
    }
    
    private func propegateStatusChange() {
        delegate?.statusDidChange(to: status)
    }
    
    func startCountUpTo(targetInSeconds: Int) {
        startDate = Date()
        timer?.invalidate()
        status = .ticking(0, targetInSeconds)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let timepassed = Int(Date().timeIntervalSince(self.startDate))
            switch self.status {
            case .ticking(let current, let target):
                let isInfiniteCounter = target == 0 && current == 0
                if current == target && !isInfiniteCounter {
                    self.status = .done
                    self.timer?.invalidate()
                    return
                } else {
                    self.status = .ticking(timepassed, target)
                }
            case .inactive:
                print("Timer was inactive")
            case .done:
                print("Timer was done. Invalidating")
                self.timer?.invalidate()
            }
        }
    }
}


protocol AKTimerStatusBarDelegate {
    func statusBarDidFinish(_ bool: Bool)
}
