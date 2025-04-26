import UIKit
import AKKIT

class StripesView: UIView {
    
    // MARK: - Properties
    
    private var stripesLayer: CAShapeLayer?
    private var stripeCount: Int = 3 // Default to 3 stripes
    private var stripeColor: UIColor = .white
    private var stripeWidth: CGFloat = 8.0
    private var stripeSpacing: CGFloat = 16.0
    private var stripeAngle: CGFloat = .pi / 4
    private var stripeInset: CGFloat = 0.2
    private var hexPath: UIBezierPath?
    private var maxStripeCount: Int = 10 // Maximum number of stripes
    
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
        backgroundColor = .clear
        isUserInteractionEnabled = false
        
        // Create stripes layer
        let newStripesLayer = CAShapeLayer()
        newStripesLayer.fillColor = nil
        newStripesLayer.lineCap = .round
        layer.addSublayer(newStripesLayer)
        stripesLayer = newStripesLayer
        
        clipsToBounds = false
    }
    
    // MARK: - Public Methods

    /// Configure the stripes appearance
    /// - Parameters:
    ///   - count: Number of stripes to display
    ///   - color: Color of the stripes
    ///   - width: Width of each stripe
    ///   - spacing: Spacing between stripes
    ///   - angle: Angle of the stripes in radians (default is π/4 or 45°)
    ///   - inset: How much to inset the stripes from the edges (0.0-1.0, where 0.2 means 20% inset)
    ///   - maxCount: Maximum number of stripes (default is 10)
    func configureStripes(count: Int = 3,
                          color: UIColor = .white,
                          width: CGFloat = 8.0,
                          spacing: CGFloat = 16.0,
                          angle: CGFloat = .pi / 4,
                          inset: CGFloat = 0.2,
                          maxCount: Int = 10) {
        self.stripeCount = count
        self.stripeColor = color
        self.stripeWidth = width
        self.stripeSpacing = spacing
        self.stripeAngle = angle
        self.stripeInset = max(0, min(inset, 0.9)) // Clamp between 0 and 0.9
        self.maxStripeCount = maxCount
        
        updateStripesPath()
    }
    
    /// Animate a "bump" effect on the stripes and optionally increase the stripe count
    /// - Parameters:
    ///   - duration: Duration of the animation
    ///   - scale: How much to scale the stripes during the bump (1.0 = no change)
    ///   - increaseCount: Whether to increase the stripe count (default is true)
    ///   - completion: Optional completion handler
    func bumpStripes(duration: TimeInterval = 0.3,
                     scale: CGFloat = 1.2,
                     increaseCount: Bool = true,
                     completion: (() -> Void)? = nil) {
        guard let stripesLayer = stripesLayer else {
            completion?()
            return
        }
        
        // Increase stripe count if requested and below max
        if increaseCount && stripeCount < maxStripeCount {
            stripeCount += 1
            // We'll update the stripes path after the animation completes
        }
        
        UIView.animate(withDuration: 1) {
            let scale = 0.9
            self.transform = self.transform.scaledBy(x: scale, y: scale)
        }
        
        // Store original transform
        let originalTransform = stripesLayer.transform
        
        // Create scale transform
        let scaleTransform = CATransform3DMakeScale(scale, scale, 1.0)
        
        // Create animations
        let scaleAnimation = CABasicAnimation(keyPath: "transform")
        scaleAnimation.fromValue = originalTransform
        scaleAnimation.toValue = scaleTransform
        scaleAnimation.duration = duration / 2
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        let reverseAnimation = CABasicAnimation(keyPath: "transform")
        reverseAnimation.fromValue = scaleTransform
        reverseAnimation.toValue = originalTransform
        reverseAnimation.duration = duration / 2
        reverseAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        reverseAnimation.beginTime = duration / 2
        
        // Group animations
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [scaleAnimation, reverseAnimation]
        groupAnimation.duration = duration
        
        // Add completion handler
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            // Update the stripes path with the new count
            self.updateStripesPath()
            
            // Call the provided completion handler if any
            completion?()
        }
        stripesLayer.add(groupAnimation, forKey: "bumpAnimation")
        CATransaction.commit()
        
        // Add haptic feedback
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
    }
    
    /// Get the current stripe count
    func getStripeCount() -> Int {
        return stripeCount
    }
    
    /// Reset stripe count to a specific value
    func resetStripeCount(to count: Int = 3) {
        stripeCount = max(0, min(count, maxStripeCount))
        updateStripesPath()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateStripesPath()
    }
    
    // MARK: - Private Methods
    
    private func updateStripesPath() {
        guard let stripesLayer = stripesLayer,
              stripeCount > 0,
              bounds.width > 0,
              bounds.height > 0 else {
            return
        }
        
        // Create a path for all stripes
        let path = UIBezierPath()
        
        // Get the view's bounds
        let viewBounds = bounds
        let center = CGPoint(x: viewBounds.midX, y: viewBounds.midY)
        let radius = min(viewBounds.width, viewBounds.height) / 2
        
        // Calculate the diagonal length with inset
        let diagonalLength = radius * 2.0 * (1.0 - stripeInset)
        
        // Calculate offset to center the stripes
        let totalWidth = CGFloat(stripeCount - 1) * stripeSpacing
        let startOffset = -totalWidth / 2
        
        // Draw each stripe
        for i in 0..<stripeCount {
            let offset = startOffset + CGFloat(i) * stripeSpacing
            
            // Calculate start and end points for the stripe
            // We rotate these points based on the stripeAngle
            let rotatedOffset = CGPoint(
                x: offset * cos(stripeAngle),
                y: offset * sin(stripeAngle)
            )
            
            // Direction vector perpendicular to the offset
            let dirX = cos(stripeAngle + .pi/2)
            let dirY = sin(stripeAngle + .pi/2)
            
            let startPoint = CGPoint(
                x: center.x + rotatedOffset.x - dirX * diagonalLength/2,
                y: center.y + rotatedOffset.y - dirY * diagonalLength/2
            )
            
            let endPoint = CGPoint(
                x: center.x + rotatedOffset.x + dirX * diagonalLength/2,
                y: center.y + rotatedOffset.y + dirY * diagonalLength/2
            )
            
            // Add the line to the path
            path.move(to: startPoint)
            path.addLine(to: endPoint)
        }
        
        // Update the stripes layer
        stripesLayer.path = path.cgPath
        stripesLayer.strokeColor = stripeColor.cgColor
        stripesLayer.lineWidth = stripeWidth
    }
}
