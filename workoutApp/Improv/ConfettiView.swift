import UIKit

class ConfettiView: UIView {
    private var emitter: CAEmitterLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        emitter = CAEmitterLayer()
        // We'll set the position dynamically when triggered
        emitter.emitterPosition = CGPoint.zero
        // Use a point shape for a cannon-like effect
        emitter.emitterShape = .point
        // Small emitter size for concentrated burst
        emitter.emitterSize = CGSize(width: 10, height: 10)
        // Additive rendering for brighter colors
        emitter.renderMode = .additive
        
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
            // Higher birth rate for more particles
            cell.birthRate = 100
            // Shorter lifetime for a quick burst
            cell.lifetime = 2.0
            cell.lifetimeRange = 1.0
            // Higher velocity for explosive effect
            cell.velocity = 350
            cell.velocityRange = 150
            // Emit in all directions (360 degrees)
            cell.emissionRange = .pi * 2
            cell.spin = 3.5
            cell.spinRange = 4
            // Start larger and shrink
            cell.scale = 0.1
            cell.scaleRange = 0.1
            cell.scaleSpeed = -0.03
            // Add some physics
            cell.yAcceleration = 70 // gravity
            // Create different shapes for variety
            cell.contents = createConfettiShape(color: color)
            
            cells.append(cell)
        }
        
        emitter.emitterCells = cells
        layer.addSublayer(emitter)
        
        // Initially hidden
        emitter.birthRate = 0
    }
    
    private func createConfettiShape(color: UIColor) -> CGImage? {
        let size = CGSize(width: 8, height: 8)
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
        // Update emitter position to the tap location
        emitter.emitterPosition = position
        
        // Create a burst effect by briefly setting a high birth rate
        emitter.birthRate = 1
        
        // Explosive animation
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.1)
        emitter.beginTime = CACurrentMediaTime()
        CATransaction.commit()
        
        // Stop emitting after a very short duration (cannon burst effect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.emitter.birthRate = 0
        }
    }
}
