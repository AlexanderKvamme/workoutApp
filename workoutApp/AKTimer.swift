//
//  AKTimer.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/12/2022.
//  Copyright © 2022 Alexander Kvamme. All rights reserved.
//

import Foundation


class AKTimer {
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
    
    func startCountUpTo(_ targetMinutes: Int) {
        let targetSeconds = targetMinutes*60
        
        timer?.invalidate()
        status = .ticking(0, targetSeconds)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            switch self.status {
            case .ticking(let current, let target):
                if current == target {
                    self.status = .done
                    self.timer?.invalidate()
                    return
                } else {
                    self.status = .ticking(current+1, target)
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
