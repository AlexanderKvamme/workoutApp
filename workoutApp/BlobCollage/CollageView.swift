import UIKit
import Lottie

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
    
    // Lottie configuration
    var lottieFiles: [String] = ["lottie1", "lottie2", "lottie3", "lottie4", "lottie5", "lottie6"]
    var lottieSize: CGFloat = 200
    
    // MARK: - Private Properties
    private var shapedContainers: [ShapedImageContainerView] = []
    private let centerContainer = ShapedImageContainerView()
    private var lottieViews: [LottieAnimationView] = []
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
        createLottieViews()
        setupInitialPositions()
    }
    
    func startAnimation() {
        guard !isAnimated else { return }
        isAnimated = true
        animateShapesOut()
    }
    
    func resetAnimation() {
        isAnimated = false
        setupCollage()
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
        
        // Clear Lottie views
        lottieViews.forEach {
            $0.stop()
            $0.removeFromSuperview()
        }
        lottieViews.removeAll()
    }
    
    private func createShapes() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        // Create large center shape
        setupCenterShape(at: center)
        
        // Create first batch of surrounding shapes (these will be behind Lottie views)
        createFirstBatchSecondaryShapes(around: center)
    }
    
    private func createLottieViews() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        // Create Lottie views between collage items
        for i in 0..<surroundingShapesCount {
            let lottieFileName = lottieFiles[i % lottieFiles.count]
            let lottieView = LottieAnimationView(name: lottieFileName)
            
            lottieView.frame = CGRect(x: 0, y: 0, width: lottieSize, height: lottieSize)
            lottieView.center = center
            lottieView.contentMode = .scaleAspectFit
            lottieView.loopMode = LottieLoopMode.playOnce
            lottieView.alpha = 0.0
            
            // Add red tint using color value provider
            let colorProvider = ColorValueProvider(UIColor.akBlue.lottieColorValue)
            lottieView.setValueProvider(colorProvider, keypath: AnimationKeypath(keypath: "**.Color"))
            
            // Add Lottie views (they'll be over the first batch of secondary images)
            addSubview(lottieView)
            lottieViews.append(lottieView)
        }
        
        // Add the remaining secondary images (these will be IN FRONT of Lottie views)
        addRemainingSecondaryShapes()
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
    
    private func createFirstBatchSecondaryShapes(around center: CGPoint) {
        let shapes: [ContainerShape] = [.circle, .roundedRectangleWide, .rectangleTall, .roundedRectangleWide, .roundedRectangleTall]
        
        // First batch: These will be BEHIND Lottie views
        let behindLottieCount = surroundingShapesCount / 2
        for i in 0..<behindLottieCount {
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
    
    private func addRemainingSecondaryShapes() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let shapes: [ContainerShape] = [.circle, .roundedRectangleWide, .rectangleTall, .roundedRectangleWide, .roundedRectangleTall]
        
        // Second batch: These will be IN FRONT of Lottie views
        let behindLottieCount = surroundingShapesCount / 2
        let frontCount = surroundingShapesCount - behindLottieCount
        
        for i in 0..<frontCount {
            let actualIndex = behindLottieCount + i
            let container = ShapedImageContainerView()
            container.shapeType = shapes[actualIndex % shapes.count]
            container.borderWidth = CGFloat.random(in: 8...12)
            container.borderColor = borderColor
            container.shadowOffset = CGSize(width: 15, height: 15)
            container.image = UIImage(named: images[(actualIndex + 1) % images.count]) ?? createPlaceholderImage(color: .systemGray2)
            
            // Random sizes for variety
            let size = CGFloat.random(in: surroundingShapeSizeRange.min...surroundingShapeSizeRange.max)
            container.frame = CGRect(x: 0, y: 0, width: size, height: size)
            
            // Random rotation for more dynamic look
            container.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: -0.3...0.3))
            
            // These go in front of Lottie views
            addSubview(container)
            shapedContainers.append(container)
        }
    }
    
    private func setupInitialPositions() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        // Position all smaller shapes exactly at the center
        for container in shapedContainers {
            container.center = center
            container.alpha = 0.0
            container.transform = container.transform.scaledBy(x: 0.9, y: 0.9)
        }
        
        // Position Lottie views at center initially
        for lottieView in lottieViews {
            lottieView.center = center
            lottieView.alpha = 0.0
            lottieView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
    }
    
    private func animateShapesOut() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        // Radial positioning
        let angles: [CGFloat] = [90, 162, 234, 306, 18] // Top, upper left, lower left, lower right, upper right
        let distanceMultipliers: [CGFloat] = [1.0, 1.0, 1.0, 1.0, 1.0]
        
        // Calculate final positions using radial coordinates
        var finalPositions: [CGPoint] = []
        var lottiePositions: [CGPoint] = []
        
        for (index, angle) in angles.enumerated() {
            let angleInRadians = angle * .pi / 180
            let distance = baseDistance * distanceMultipliers[index % distanceMultipliers.count]
            
            let x = center.x + cos(angleInRadians) * distance
            let y = center.y + sin(angleInRadians) * distance
            
            finalPositions.append(CGPoint(x: x, y: y))
            
            // Position Lottie views between center and final positions
            let lottieDistance = distance * 0.6 // 60% of the way out
            let lottieX = center.x + cos(angleInRadians) * lottieDistance
            let lottieY = center.y + sin(angleInRadians) * lottieDistance
            lottiePositions.append(CGPoint(x: lottieX, y: lottieY))
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
        
        // Animate Lottie views to their positions
        for (index, lottieView) in lottieViews.enumerated() {
            let lottiePosition = lottiePositions[index % lottiePositions.count]
            let delay = Double(index) * animationDelay + 0.0 // Slight delay after shapes
            
            UIView.animate(
                withDuration: animationDuration * 0.8,
                delay: delay,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.2,
                options: [.curveEaseOut]
            ) {
                lottieView.center = lottiePosition
                lottieView.alpha = 0.8
                lottieView.transform = .identity
            }
        }
        
        // Start ALL Lottie animations at the same time
        let lottieStartDelay = 0.5 // When to start all Lottie animations
        DispatchQueue.main.asyncAfter(deadline: .now() + lottieStartDelay) {
            for lottieView in self.lottieViews {
                lottieView.play()
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
