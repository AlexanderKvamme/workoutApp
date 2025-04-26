import UIKit

class ConfettiView: UIView {
    // Keep track of active emitters
    private var emitters: [CAEmitterLayer] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    // Create a fresh emitter each time instead of reusing
    private func createEmitterLayer(at position: CGPoint) -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = position
        emitter.emitterShape = .point
        emitter.emitterSize = CGSize(width: 20, height: 20)
        emitter.renderMode = .additive
        
        // Create cells with the exact same visual properties as the original
        let colors: [UIColor] = [
            .systemRed,
            .systemBlue,
            .systemGreen,
            .systemYellow,
            .systemPurple,
            .systemOrange,
            .systemPink,
            .systemTeal
        ]
        
        var cells: [CAEmitterCell] = []
        
        for color in colors {
            let cell = CAEmitterCell()
            // Exactly the same parameters as your original code
            cell.birthRate = 100
            cell.lifetime = 2.0
            cell.lifetimeRange = 1.0
            cell.velocity = 600
            cell.velocityRange = 200
            cell.emissionRange = .pi * 2
            cell.spin = 3.5
            cell.spinRange = 4
            cell.scale = 0.1
            cell.scaleRange = 0.1
            cell.scaleSpeed = -0.03
            cell.yAcceleration = 70
            cell.contents = createConfettiShape(color: color)
            
            cells.append(cell)
        }
        
        emitter.emitterCells = cells
        return emitter
    }
    
    private func createConfettiShape(color: UIColor) -> CGImage? {
        // Exactly the same shape creation as your original code
        let size = CGSize(width: 24, height: 24)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Randomly choose between different shapes
        let shapeType = Int.random(in: 0...2)
        
        context.setFillColor(color.cgColor)
        
        switch shapeType {
        case 0: // Circle
            context.fillEllipse(in: CGRect(origin: .zero, size: size))
        case 1: // Square
            context.fill(CGRect(origin: .zero, size: size))
        case 2: // Triangle
            let path = UIBezierPath()
            path.move(to: CGPoint(x: size.width/2, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            path.close()
            
            color.setFill()
            path.fill()
        default:
            context.fill(CGRect(origin: .zero, size: size))
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.cgImage
    }
    
    func startConfettiCannon(at position: CGPoint) {
        print("Starting cannon at position: \(position)")
        
        // Ensure we're on the main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.startConfettiCannon(at: position)
            }
            return
        }
        
        // Create a fresh emitter for this burst
        let emitter = createEmitterLayer(at: position)
        layer.addSublayer(emitter)
        emitters.append(emitter)
        
        // Start emitting - exactly like your original code
        emitter.birthRate = 1
        
        // Explosive animation - exactly like your original code
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.1)
        emitter.beginTime = CACurrentMediaTime()
        CATransaction.commit()
        
        // Stop emitting after a short duration - exactly like your original code
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            emitter.birthRate = 0
            
            // Clean up after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                emitter.removeFromSuperlayer()
                if let index = self?.emitters.firstIndex(where: { $0 === emitter }) {
                    self?.emitters.remove(at: index)
                }
            }
        }
    }
    
    // Clean up method - call this when the view is about to be removed
    func cleanup() {
        for emitter in emitters {
            emitter.removeFromSuperlayer()
        }
        emitters.removeAll()
    }
    
    // Override removeFromSuperview to ensure cleanup
    override func removeFromSuperview() {
        cleanup()
        super.removeFromSuperview()
    }
}
