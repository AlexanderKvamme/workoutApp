

import UIKit

class CollageView: UIView {
    
    // MARK: - Configuration Properties
    var images: [String] = ["md-image-1", "md-image-2", "md-image-3", "md-image-4"]
    var centerShapeSize: CGFloat = 180
    var surroundingShapesCount: Int = 5
    var surroundingShapeSizeRange: (min: CGFloat, max: CGFloat) = (110, 140)
    var baseDistance: CGFloat = 160
    var borderColor: UIColor = .black
    var initialClusterRadius: CGFloat = 20
    var animationDuration: TimeInterval = 1.0
    var animationDelay: TimeInterval = 0.0
    
    // MARK: - Private Properties
    private var shapedContainers: [ShapedImageContainerView] = []
    private let centerContainer = ShapedImageContainerView()
    private var isAnimated = false
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Public Methods
    func setupCollage() {
        clearExistingShapes()
        createShapes()
        setupInitialPositions()
    }
    
    func startAnimation() {
        guard !isAnimated else { return }
        isAnimated = true
        animateShapesOut()
    }
    
    func resetAnimation() {
        isAnimated = false
        setupCollage()  // Add this line to ensure shapes are created
        setupInitialPositions()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.startAnimation()
        }
    }

    
    // MARK: - Private Methods
    private func clearExistingShapes() {
        shapedContainers.forEach { $0.removeFromSuperview() }
        shapedContainers.removeAll()
        centerContainer.removeFromSuperview()
    }
    
    private func createShapes() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        // Create large center shape
        setupCenterShape(at: center)
        
        // Create smaller surrounding shapes
        createSurroundingShapes(around: center)
    }
    
    private func setupCenterShape(at center: CGPoint) {
        centerContainer.shapeType = .roundedSquare
        centerContainer.borderWidth = 15
        centerContainer.borderColor = borderColor
        centerContainer.shadowOffset = CGSize(width: 20, height: 20)
        centerContainer.image = UIImage(named: images.first ?? "") ?? createPlaceholderImage(color: .systemGray2)
        
        centerContainer.frame = CGRect(
            x: center.x - centerShapeSize/2,
            y: center.y - centerShapeSize/2,
            width: centerShapeSize,
            height: centerShapeSize
        )
        
        addSubview(centerContainer)
    }
    
    private func createSurroundingShapes(around center: CGPoint) {
        let shapes: [ContainerShape] = [.circle, .roundedRectangleWide, .rectangleTall, .roundedRectangleWide, .roundedRectangleTall]
        
        for i in 0..<surroundingShapesCount {
            let container = ShapedImageContainerView()
            container.shapeType = shapes[i % shapes.count]
            container.borderWidth = CGFloat.random(in: 8...12)
            container.borderColor = borderColor
            container.shadowOffset = CGSize(width: 15, height: 15)
            container.image = UIImage(named: images[(i + 1) % images.count]) ?? createPlaceholderImage(color: .systemGray2)
            
            // Random sizes for variety
            let size = CGFloat.random(in: surroundingShapeSizeRange.min...surroundingShapeSizeRange.max)
            container.frame = CGRect(x: 0, y: 0, width: size, height: size)
            
            // Random rotation for more dynamic look
            container.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: -0.3...0.3))
            
            addSubview(container)
            shapedContainers.append(container)
        }
    }
    
    private func setupInitialPositions() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        // Position all smaller shapes exactly at the center (on top of main image)
        for container in shapedContainers {
            // Start exactly at the center of the main image
            container.center = center
            container.alpha = 0.8
            container.transform = container.transform.scaledBy(x: 0.9, y: 0.9)
        }
    }
    
    private func animateShapesOut() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        // Radial positioning
        let angles: [CGFloat] = [90, 162, 234, 306, 18] // Top, upper left, lower left, lower right, upper right
        let distanceMultipliers: [CGFloat] = [1.0, 1.0, 1.0, 1.0, 1.0]
        
        // Calculate final positions using radial coordinates
        var finalPositions: [CGPoint] = []
        for (index, angle) in angles.enumerated() {
            let angleInRadians = angle * .pi / 180
            let distance = baseDistance * distanceMultipliers[index % distanceMultipliers.count]
            
            let x = center.x + cos(angleInRadians) * distance
            let y = center.y + sin(angleInRadians) * distance
            
            finalPositions.append(CGPoint(x: x, y: y))
        }
        
        // Animate each shape to its final position
        for (index, container) in shapedContainers.enumerated() {
            let finalPosition = finalPositions[index % finalPositions.count]
            let delay = Double(index) * animationDelay
            
            UIView.animate(
                withDuration: animationDuration,
                delay: delay,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0.3,
                options: [.curveEaseOut]
            ) {
                container.center = finalPosition
                container.alpha = 1.0
                container.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: -0.2...0.2))
            }
        }
        
        // Animate center shape with a subtle bounce
        UIView.animate(
            withDuration: 0.8,
            delay: 0.5,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.2
        ) {
            self.centerContainer.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { _ in
            UIView.animate(withDuration: 0.4) {
                self.centerContainer.transform = .identity
            }
        }
    }
    
    private func createPlaceholderImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
