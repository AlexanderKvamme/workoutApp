import UIKit

class GradientBorderButton: UIButton {
    // Gradient layers
    private let gradientLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()
    
    // Configuration
    var borderWidth: CGFloat = 3.0 {
        didSet { updateGradientBorder() }
    }
    
    var gradientColors: [UIColor] = [.black, .gray] {
        didSet { updateGradientBorder() }
    }
    
    // Track the current animated border width
    private var currentBorderWidth: CGFloat = 0.0
    
    // Spring animation properties
    private var springVelocity: CGFloat = 0
    private var springTargetWidth: CGFloat = 0
    private var lastUpdateTime: CFTimeInterval = 0
    private var displayLink: CADisplayLink?
    private var animationCompletion: (() -> Void)?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientBorder()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradientBorder()
    }
    
    private func setupGradientBorder() {
        // Create shape layer for border
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 0  // Start with zero width
        currentBorderWidth = 0    // Track current width
        
        // Create gradient layer
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        
        // Add to layer
        layer.addSublayer(gradientLayer)
        gradientLayer.mask = shapeLayer
        
        // Initial update
        updateGradientBorder()
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientBorder()
    }
    
    private func updateGradientBorder() {
        // Update gradient frame
        gradientLayer.frame = bounds
        
        // Update border path
        let inset = currentBorderWidth / 2
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: inset, dy: inset),
                               cornerRadius: layer.cornerRadius)
        shapeLayer.path = path.cgPath
        
        // Update gradient colors
        gradientLayer.colors = gradientColors.map { $0.cgColor }
    }
    
    // MARK: - Animation Methods
    
    // Animate the border thickness with spring effect
    func animateBorderIn(duration: TimeInterval = 0.8, completion: (() -> Void)? = nil) {
        // Stop any existing animations
        stopBorderAnimation()
        
        // Store the target border width
        springTargetWidth = borderWidth
        springVelocity = 0
        currentBorderWidth = 0
        shapeLayer.lineWidth = 0
        lastUpdateTime = CACurrentMediaTime()
        animationCompletion = completion
        
        // Create a display link for smooth animation with spring physics
        displayLink = CADisplayLink(target: self, selector: #selector(updateSpringAnimation))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    private func stopBorderAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateSpringAnimation() {
        // Spring physics parameters
        let damping: CGFloat = 12.0  // Higher = less oscillation
        let tension: CGFloat = 120.0  // Higher = faster animation
        
        // Calculate time delta
        let now = CACurrentMediaTime()
        let deltaTime = CGFloat(now - lastUpdateTime)
        lastUpdateTime = now
        
        // Spring physics
        let displacement = springTargetWidth - currentBorderWidth
        let springForce = tension * displacement
        let dampingForce = damping * springVelocity
        
        let acceleration = springForce - dampingForce
        springVelocity += acceleration * deltaTime
        currentBorderWidth += springVelocity * deltaTime
        
        // Update the border width
        shapeLayer.lineWidth = currentBorderWidth
        
        // Update the path with new inset
        let inset = currentBorderWidth / 2
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: inset, dy: inset),
                               cornerRadius: layer.cornerRadius)
        shapeLayer.path = path.cgPath
        
        // Check if we're close enough to stop
        if abs(currentBorderWidth - springTargetWidth) < 0.1 && abs(springVelocity) < 0.1 {
            // Stop the animation
            stopBorderAnimation()
            
            // Set final value
            currentBorderWidth = springTargetWidth
            shapeLayer.lineWidth = currentBorderWidth
            
            // Update path one last time
            let finalInset = currentBorderWidth / 2
            let finalPath = UIBezierPath(roundedRect: bounds.insetBy(dx: finalInset, dy: finalInset),
                                        cornerRadius: layer.cornerRadius)
            shapeLayer.path = finalPath.cgPath
            
            // Call completion
            if let completion = animationCompletion {
                animationCompletion = nil
                completion()
            }
        }
    }
    
    // Simpler animation method using UIView animations
    func animateBorderInSimple(duration: TimeInterval = 0.6, completion: (() -> Void)? = nil) {
        // Start with zero border width
        currentBorderWidth = 0
        shapeLayer.lineWidth = 0
        
        // Update path with zero inset
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
        shapeLayer.path = path.cgPath
        
        // Use UIView animation for simpler spring effect
        UIView.animate(withDuration: duration,
                      delay: 0,
                      usingSpringWithDamping: 0.5,  // Lower = more bounce
                      initialSpringVelocity: 6.0,   // Higher = more initial velocity
                      options: .curveEaseOut,
                      animations: {
            // Animate to target border width
            self.currentBorderWidth = self.borderWidth
            self.shapeLayer.lineWidth = self.borderWidth
            
            // Update path with new inset
            let inset = self.borderWidth / 2
            let path = UIBezierPath(roundedRect: self.bounds.insetBy(dx: inset, dy: inset),
                                   cornerRadius: self.layer.cornerRadius)
            self.shapeLayer.path = path.cgPath
            
        }, completion: { _ in
            completion?()
        })
    }
    
    // Rotate gradient around the border
    func startRotatingGradient(duration: TimeInterval = 3.0) {
        // Stop any existing animations
        stopGradientAnimation()
        
        // For a rotating gradient effect, we'll animate the start and end points
        // Create a group animation for smooth rotation
        let animation = CAAnimationGroup()
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        
        // Animate startPoint in a circle
        let startPointAnimation = CAKeyframeAnimation(keyPath: "startPoint")
        let startPointValues = [
            CGPoint(x: 0, y: 0),      // Top-left
            CGPoint(x: 1, y: 0),      // Top-right
            CGPoint(x: 1, y: 1),      // Bottom-right
            CGPoint(x: 0, y: 1),      // Bottom-left
            CGPoint(x: 0, y: 0)       // Back to top-left
        ]
        startPointAnimation.values = startPointValues
        startPointAnimation.calculationMode = .paced
        
        // Animate endPoint in a circle (offset from startPoint)
        let endPointAnimation = CAKeyframeAnimation(keyPath: "endPoint")
        let endPointValues = [
            CGPoint(x: 1, y: 1),      // Bottom-right
            CGPoint(x: 0, y: 1),      // Bottom-left
            CGPoint(x: 0, y: 0),      // Top-left
            CGPoint(x: 1, y: 0),      // Top-right
            CGPoint(x: 1, y: 1)       // Back to bottom-right
        ]
        endPointAnimation.values = endPointValues
        endPointAnimation.calculationMode = .paced
        
        // Combine animations
        animation.animations = [startPointAnimation, endPointAnimation]
        
        // Add the animation
        gradientLayer.add(animation, forKey: "rotateGradient")
    }
    
    func stopGradientAnimation() {
        gradientLayer.removeAllAnimations()
        
        // Reset to default positions
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    }
}

