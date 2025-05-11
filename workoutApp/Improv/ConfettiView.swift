import UIKit
//let CONFETTI_COLORS: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemYellow,
//                        .systemPurple, .systemOrange, .systemPink, .systemTeal]
let CONFETTI_COLORS: [UIColor] = [.akRed, .akGreen, .akOrange, .akBlue, .akPurple]

class ConfettiView: UIView {
    // Track all active confetti pieces
    private var activeConfetti: [UIView] = []
    private var isAnimating = false
    private var keepConfetti = false
    var removalPoint: CGPoint? = CGPoint(x: 100, y: 200)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    // Clean up any lingering confetti
    func cleanup() {
        for confetti in activeConfetti {
            confetti.removeFromSuperview()
        }
        activeConfetti.removeAll()
        isAnimating = false
        keepConfetti = false
    }
    
    override func removeFromSuperview() {
        cleanup()
        super.removeFromSuperview()
    }
    
    func startConfettiCannon(at position: CGPoint, keepOnScreen: Bool = false) {
        // Ensure we're on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.startConfettiCannon(at: position, keepOnScreen: keepOnScreen)
            }
            return
        }
        
        // Store the keep confetti preference
        self.keepConfetti = keepOnScreen
        
        // If already animating, clean up first
        if isAnimating {
            cleanup()
        }
        
        isAnimating = true
        print("DEBUG: Starting confetti from behind at \(position)")
        
        // Create confetti pieces
        let colors: [UIColor] = CONFETTI_COLORS
        
        // Create 60 confetti pieces
        for _ in 0..<60 {
            // Create a confetti piece
            let size = CGFloat.random(in: 8...24)
            let confetti = UIView(frame: CGRect(x: position.x - size/2, y: position.y - size/2,
                                              width: size, height: size))
            
            // Random color
            confetti.backgroundColor = colors.randomElement()
            
            // Random shape
            let shapeType = Int.random(in: 0...3)
            switch shapeType {
            case 0: // Circle
                confetti.layer.cornerRadius = size / 2
            case 1: // Square
                confetti.layer.cornerRadius = 0
            case 2: // Diamond
                confetti.transform = CGAffineTransform(rotationAngle: .pi / 4)
            case 3: // Rectangle
                confetti.frame = CGRect(x: position.x - size/2, y: position.y - size/4,
                                       width: size, height: size/2)
            default:
                break
            }
            
            // Add to view and tracking array
            addSubview(confetti)
            activeConfetti.append(confetti)
            
            // Random direction - but make it burst outward from the center
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 200...400)
            let travelDuration: TimeInterval = TimeInterval.random(in: 0.7...1.0)
            let shrinkDuration: TimeInterval = 0.2
            let delay = TimeInterval.random(in: 0...0.1)
            let shrinkDelay = delay + travelDuration
            confetti.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            // Add a slight "pop" at the beginning
            UIView.animate(withDuration: 0.05, delay: delay, options: [.beginFromCurrentState], animations: {
                confetti.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: nil)
            
            // Main travel animation
            UIView.animate(withDuration: travelDuration, delay: delay,
                          usingSpringWithDamping: 0.7,
                          initialSpringVelocity: 0.5,
                          options: [.allowUserInteraction, .beginFromCurrentState], animations: {
                // Move in random direction from the center
                confetti.center = CGPoint(
                    x: position.x + cos(angle) * distance,
                    y: position.y + sin(angle) * distance + distance/2 // Add some gravity
                )
                
                // Rotate
                confetti.transform = confetti.transform.rotated(by: .pi * 2 * CGFloat.random(in: 1...3))
                confetti.transform = confetti.transform.scaledBy(x: 0.7, y: 0.7)
            }, completion: nil)
            
            // Only add the shrink animation if we're not keeping confetti
            if let removalPoint = removalPoint {
                let minDelay = 1.5
                let delay = CGFloat.random(in: minDelay+0.2...minDelay+0.45)
                let duration = 0.3
                UIView.animate(withDuration: duration,
                               delay: delay,
                               usingSpringWithDamping: 1.0,
                               initialSpringVelocity: 1.0,
                              options: [.allowUserInteraction, .beginFromCurrentState], animations: {
                    // Move in random direction from the center
                    confetti.center = removalPoint
                    confetti.transform = confetti.transform.rotated(by: .pi * 2 * CGFloat.random(in: 1...3))
                    
                    // Scale down slightly as it moves away
                    confetti.transform = confetti.transform.scaledBy(x: 0.7, y: 0.7)
                }, completion: nil)
            } else if !keepOnScreen {
                // Shrink animation at the end
                UIView.animate(withDuration: shrinkDuration, delay: shrinkDelay,
                              options: [.beginFromCurrentState], animations: {
                    // Shrink to nothing at the final position
                    confetti.transform = confetti.transform.scaledBy(x: 0.01, y: 0.01)
                }, completion: { _ in
                    // Remove this specific confetti piece
                    confetti.removeFromSuperview()
                    if let index = self.activeConfetti.firstIndex(where: { $0 === confetti }) {
                        self.activeConfetti.remove(at: index)
                    }
                    
                    // If this was the last piece, reset animation state
                    if self.activeConfetti.isEmpty {
                        self.isAnimating = false
                        print("DEBUG: All confetti removed naturally")
                    }
                })
            }
        }
        
        // Safety cleanup timer in case some animations don't complete
        // Only needed if we're not keeping confetti
        if !keepOnScreen {
            let maxDuration: TimeInterval = 1.5  // Maximum possible animation time
            
            // Cancel any previous cleanup timers
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(safetyCleanup), object: nil)
            
            // Schedule new safety cleanup
            perform(#selector(safetyCleanup), with: nil, afterDelay: maxDuration)
            
            print("DEBUG: Created 60 confetti pieces with individual shrink animations")
        } else {
            print("DEBUG: Created 60 confetti pieces that will remain visible")
        }
    }
    
    @objc private func safetyCleanup() {
        // Only run if there are still active confetti pieces and we're not keeping them
        if !activeConfetti.isEmpty && !keepConfetti {
            print("DEBUG: Safety cleanup triggered for \(activeConfetti.count) remaining pieces")
            cleanup()
        }
    }
    
    // Method to remove confetti if needed later
    func removeConfetti() {
        // If we're keeping confetti, provide a way to remove it later
        if !activeConfetti.isEmpty {
            for confetti in activeConfetti {
                UIView.animate(withDuration: 0.3, animations: {
                    confetti.alpha = 0
                }, completion: { _ in
                    confetti.removeFromSuperview()
                })
            }
            
            // Schedule cleanup after animations complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.activeConfetti.removeAll()
                self?.keepConfetti = false
                self?.isAnimating = false
            }
        }
    }
}
