import UIKit

class GradientBorderView: UIView {
    // MARK: - Properties
    var gradientColors: [UIColor] = [.systemGreen, .systemMint] {
        didSet {
            updateGradientLayer()
        }
    }
    
    var borderWidth: CGFloat = 2.0 {
        didSet {
            updateGradientLayer()
        }
    }
    
    var isAnimating: Bool = false
    
    private let gradientLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Set background color to make sure view is visible
        backgroundColor = .clear
        
        // Set up shape layer for the border
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor // White mask to show gradient
        shapeLayer.lineWidth = borderWidth
        
        // Set up gradient layer
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.locations = [0.0, 1.0] // Initial locations
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // Add gradient layer to the view's layer
        layer.addSublayer(gradientLayer)
        
        // Set the shape layer as the mask for the gradient
        gradientLayer.mask = shapeLayer
        
        // Initial update
        updateGradientLayer()
        
        print("GradientBorderView initialized with colors: \(gradientColors)")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientLayer()
    }
    
    private func updateGradientLayer() {
        // Ensure we have a valid size
        guard bounds.width > 0, bounds.height > 0 else {
            print("GradientBorderView has invalid size: \(bounds)")
            return
        }
        
        // Update gradient frame to match the view's bounds
        gradientLayer.frame = bounds
        
        // Update shape layer path for the border
        let inset = borderWidth / 2.0
        let maskPath = UIBezierPath(roundedRect: bounds.insetBy(dx: inset, dy: inset),
                                   cornerRadius: layer.cornerRadius)
        shapeLayer.path = maskPath.cgPath
        shapeLayer.lineWidth = borderWidth
        
        // Update gradient colors
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        
        print("GradientBorderView updated: frame=\(bounds), borderWidth=\(borderWidth)")
    }
    
    // MARK: - Animation Methods
    func startGradientAnimation(duration: TimeInterval = 2.0, direction: Bool = true) {
        // Stop any existing animations
        stopGradientAnimation()
        
        // Set up for animation - use three colors for smooth looping
        let firstColor = gradientColors[0]
        let lastColor = gradientColors.last ?? gradientColors[0]
        
        // Create a three-color gradient for smooth animation
        gradientLayer.colors = [firstColor.cgColor, lastColor.cgColor, firstColor.cgColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        
        // Create the animation
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.5, 1.0]
        animation.toValue = direction ? [1.0, 1.5, 2.0] : [-1.0, -0.5, 0.0]
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        
        // Add the animation
        gradientLayer.add(animation, forKey: "flowAnimation")
        isAnimating = true
        
        print("GradientBorderView animation started with duration: \(duration)")
    }
    
    func stopGradientAnimation() {
        gradientLayer.removeAllAnimations()
        
        // Reset to original two-color gradient
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.locations = [0.0, 1.0]
        
        isAnimating = false
    }
    
    // Alternative animation - rotate the gradient
    func startRotatingGradient(duration: TimeInterval = 3.0) {
        // Stop any existing animations
        stopGradientAnimation()
        
        // Make sure we have a standard two-color gradient
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.locations = [0.0, 1.0]
        
        // Create a rotation animation
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = 2 * Double.pi
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        
        // Add the animation
        gradientLayer.add(animation, forKey: "rotateAnimation")
        isAnimating = true
        
        print("GradientBorderView rotation started with duration: \(duration)")
    }
}

// MARK: - Example Usage
extension GradientBorderView {
    static func createExample(in parentView: UIView) -> GradientBorderView {
        let gradientView = GradientBorderView(frame: CGRect(x: 50, y: 100, width: 200, height: 100))
        gradientView.gradientColors = [.systemBlue, .systemPurple]
        gradientView.borderWidth = 5.0  // Make it thicker for visibility
        gradientView.layer.cornerRadius = 10
        parentView.addSubview(gradientView)
        
        // Add a label to make the view more visible
        let label = UILabel(frame: gradientView.bounds.insetBy(dx: 10, dy: 10))
        label.text = "Gradient Border"
        label.textAlignment = .center
        gradientView.addSubview(label)
        
        return gradientView
    }
}
