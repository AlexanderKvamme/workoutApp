import UIKit

class GradientBorderButton: UIButton {
    // Background view with gradient border
    private let borderView = UIView()
    private let gradientLayer = CAGradientLayer()
    
    // Configuration
    var borderWidth: CGFloat = 3.0 {
        didSet { updateBorderLayout() }
    }
    
    var gradientColors: [UIColor] = [.black, .gray] {
        didSet {
            gradientLayer.colors = gradientColors.map { $0.cgColor }
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        // Setup gradient layer
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        borderView.layer.addSublayer(gradientLayer)
        borderView.alpha = 0
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superview = superview, borderView.superview == nil {
            superview.insertSubview(borderView, belowSubview: self)
            updateBorderLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBorderLayout()
    }
    
    func updateBorderLayout() {
        // Update border view frame and appearance
        borderView.frame = frame.insetBy(dx: -borderWidth, dy: -borderWidth)
        borderView.layer.cornerRadius = layer.cornerRadius + borderWidth
        borderView.clipsToBounds = true
        
        // Update gradient layer frame
        gradientLayer.frame = borderView.bounds
    }
    
    // MARK: - Animation Methods
    func animateBorderIn(duration: TimeInterval = 0.6, completion: (() -> Void)? = nil) {
        updateBorderLayout()
        borderView.alpha = 1.0
        
        // Start with border matching button size
        borderView.transform = CGAffineTransform(
            scaleX: bounds.width / borderView.bounds.width,
            y: bounds.height / borderView.bounds.height
        )
        
        // Animate to full size
        UIView.animate(
            withDuration: duration,
            animations: {
                self.borderView.transform = .identity
            },
            completion: { _ in
                completion?()
            }
        )
    }
    
    func startRotatingGradient(duration: TimeInterval = 3.0) {
        // Simple horizontal gradient animation
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = duration
        animation.repeatCount = .infinity
        
        // Make sure we have at least 3 colors for the animation
        if gradientColors.count < 3 {
            let firstColor = gradientColors.first ?? .black
            let lastColor = gradientColors.last ?? .gray
            gradientLayer.colors = [firstColor.cgColor, lastColor.cgColor, firstColor.cgColor]
        }
        
        gradientLayer.add(animation, forKey: "flowAnimation")
    }
}
