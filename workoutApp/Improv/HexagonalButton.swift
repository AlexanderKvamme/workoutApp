import UIKit

class HexagonalButton: UIButton {
    
    // MARK: - Properties
    
    private let numberLabel = UILabel()
    private let tLabel = UILabel()
    private let subLabel = UILabel()
    private let dotView = UIView()
    private let cornerRadius: CGFloat = 15.0
    
    // Long press properties
    private let longPressDuration: TimeInterval = 2.0
    private var longPressGesture: UILongPressGestureRecognizer!
    private var progressShapeLayer: CAShapeLayer?
    private var animationStartTime: CFTimeInterval?
    private var displayLink: CADisplayLink?
    private var completionHandler: (() -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
        setupLongPressGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
        setupLongPressGesture()
    }
    
    // MARK: - Setup
    
    private func setupButton() {
        // Create hexagonal shape with rounded corners
        let hexagonPath = createHexagonPath()
        
        // Create shape layer with hexagon path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = hexagonPath.cgPath
        
        // Create gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.5, green: 0.7, blue: 0.95, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        // Apply mask to gradient
        gradientLayer.mask = shapeLayer
        layer.addSublayer(gradientLayer)
        
        // Add dot view
        dotView.backgroundColor = .black
        dotView.layer.cornerRadius = 3
        addSubview(dotView)
        
        // Configure number label
        numberLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        numberLabel.textColor = .black
        numberLabel.text = "3"
        addSubview(numberLabel)
        
        // Configure title label
        tLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tLabel.textColor = .black
        tLabel.text = "walk 15 min"
        addSubview(tLabel)
        
        // Configure subtitle label
        subLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subLabel.textColor = .darkGray
        subLabel.text = "daily"
        addSubview(subLabel)
        
        // Set positions
        setNeedsLayout()
    }
    
    private func setupLongPressGesture() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.1 // Start quickly but complete after longPressDuration
        addGestureRecognizer(longPressGesture)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update gradient frame
        if let gradientLayer = layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = bounds
            if let shapeLayer = gradientLayer.mask as? CAShapeLayer {
                shapeLayer.path = createHexagonPath().cgPath
            }
        }
        
        // Position dot and number
        let centerX = bounds.width / 2
        dotView.frame = CGRect(x: centerX - 10, y: bounds.height * 0.25, width: 6, height: 6)
        numberLabel.frame = CGRect(x: centerX, y: bounds.height * 0.23, width: 20, height: 30)
        numberLabel.center.x = centerX + 5
        
        // Position title and subtitle
        tLabel.sizeToFit()
        tLabel.center.x = centerX
        tLabel.frame.origin.y = bounds.height * 0.5
        
        subLabel.sizeToFit()
        subLabel.center.x = centerX
        subLabel.frame.origin.y = tLabel.frame.maxY + 2
        
        // Update progress layer if needed
        if let progressLayer = progressShapeLayer {
            progressLayer.frame = bounds
            progressLayer.path = createHexagonPath().cgPath
        }
    }
    
    // MARK: - Path Creation
    
    private func createHexagonPath() -> UIBezierPath {
        // Use the roundedPolygonPath function
        let lineWidth: CGFloat = 0  // Set to 0 for no border or adjust as needed
        let sides = 6  // Hexagon
        let rotationOffset = CGFloat(0)  // Adjust if needed to rotate the hexagon
        
        return roundedPolygonPath(
            rect: bounds,
            lineWidth: lineWidth,
            sides: sides,
            cornerRadius: cornerRadius,
            rotationOffset: rotationOffset
        )
    }
    
    // MARK: - Rounded Polygon Path Function
    
    private func roundedPolygonPath(rect: CGRect, lineWidth: CGFloat, sides: NSInteger, cornerRadius: CGFloat, rotationOffset: CGFloat = 0) -> UIBezierPath {
        let path = UIBezierPath()
        let theta: CGFloat = CGFloat(2.0 * Double.pi) / CGFloat(sides) // How much to turn at every corner
        let width = min(rect.size.width, rect.size.height)        // Width of the square
        
        let center = CGPoint(x: rect.origin.x + width / 2.0, y: rect.origin.y + width / 2.0)
        
        // Radius of the circle that encircles the polygon
        // Notice that the radius is adjusted for the corners, that way the largest outer
        // dimension of the resulting shape is always exactly the width - linewidth
        let radius = (width - lineWidth + cornerRadius - (cos(theta) * cornerRadius)) / 2.0
        
        // Start drawing at a point, which by default is at the right hand edge
        // but can be offset
        var angle = CGFloat(rotationOffset)
        
        let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
        path.move(to: CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta)))
        
        for _ in 0..<sides {
            angle += theta
            
            let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
            let tip = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            let start = CGPoint(x: corner.x + cornerRadius * cos(angle - theta), y: corner.y + cornerRadius * sin(angle - theta))
            let end = CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta))
            
            path.addLine(to: start)
            path.addQuadCurve(to: end, controlPoint: tip)
        }
        
        path.close()
        
        // Move the path to the correct origins
        let bounds = path.bounds
        let transform = CGAffineTransform(translationX: -bounds.origin.x + rect.origin.x + lineWidth / 2.0, y: -bounds.origin.y + rect.origin.y + lineWidth / 2.0)
        path.apply(transform)
        
        return path
    }
    
    // MARK: - Long Press Handling
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            startLongPressAnimation()
        case .ended, .cancelled:
            if let startTime = animationStartTime {
                let elapsedTime = CACurrentMediaTime() - startTime
                if elapsedTime >= longPressDuration {
                    // Animation already completed, do nothing
                } else {
                    // Cancel the animation
                    cancelLongPressAnimation()
                }
            }
        default:
            break
        }
    }
    
    private func startLongPressAnimation() {
        // Cancel any existing animation
        cancelLongPressAnimation()
        
        // Create progress shape layer if needed
        if progressShapeLayer == nil {
            let progressLayer = CAShapeLayer()
            progressLayer.path = createHexagonPath().cgPath
            progressLayer.fillColor = UIColor.clear.cgColor
            progressLayer.strokeColor = UIColor.systemBlue.cgColor
            progressLayer.lineWidth = 4.0
            progressLayer.lineCap = .round
            progressLayer.strokeEnd = 0
            layer.addSublayer(progressLayer)
            progressShapeLayer = progressLayer
        }
        
        // Set up display link for smooth animation
        animationStartTime = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(updateLongPressAnimation))
        displayLink?.add(to: .main, forMode: .common)
        
        // Add haptic feedback
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    
    @objc private func updateLongPressAnimation() {
        guard let startTime = animationStartTime,
              let progressLayer = progressShapeLayer else {
            return
        }
        
        let elapsedTime = CACurrentMediaTime() - startTime
        let progress = min(elapsedTime / longPressDuration, 1.0)
        
        // Update the progress layer
        progressLayer.strokeEnd = CGFloat(progress)
        
        // Create inward filling effect by adjusting the line width
        let maxLineWidth = min(bounds.width, bounds.height) / 2
        progressLayer.lineWidth = maxLineWidth * CGFloat(progress)
        
        // Check if animation is complete
        if progress >= 1.0 {
            completeAction()
        }
    }
    
    private func cancelLongPressAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        animationStartTime = nil
        
        // Reset progress layer
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        progressShapeLayer?.strokeEnd = 0
        progressShapeLayer?.lineWidth = 4.0
        CATransaction.commit()
    }
    
    private func completeAction() {
        // Clean up animation
        displayLink?.invalidate()
        displayLink = nil
        
        // Provide haptic feedback
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedbackGenerator.impactOccurred()
        
        // Execute the completion handler
        completionHandler?()
        
        // Trigger button action
        sendActions(for: .touchUpInside)
        
        // Reset the progress layer with animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.3)
            self?.progressShapeLayer?.strokeEnd = 0
            self?.progressShapeLayer?.lineWidth = 4.0
            CATransaction.commit()
        }
    }
    
    // MARK: - Public Methods
    
    /// Set content for the button
    func configure(number: String, title: String, subtitle: String) {
        numberLabel.text = number
        tLabel.text = title
        subLabel.text = subtitle
        setNeedsLayout()
    }
    
    /// Set the action to be performed when long press completes
    func setLongPressAction(_ completion: @escaping () -> Void) {
        completionHandler = completion
    }
    
    /// Set the color of the progress animation
    func setProgressColor(_ color: UIColor) {
        progressShapeLayer?.strokeColor = color.cgColor
    }
}
