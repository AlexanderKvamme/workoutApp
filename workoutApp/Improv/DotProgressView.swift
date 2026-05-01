import UIKit

private enum DotProgressAnimation {
    static let bumpDuration: TimeInterval = 0.3
    static let completedScale: CGFloat = 1.1
    static let shakeXValues: [CGFloat] = [0, -3.5, 5, -4.5, 3.5, -2, 0]
    static let shakeYValues: [CGFloat] = [0, 2.5, -3.5, 3, -2.5, 1.5, 0]
    static let shakeKeyTimes: [NSNumber] = [0, 0.16, 0.32, 0.5, 0.68, 0.84, 1]
}

protocol DotProgressDelegate {
//    func didComplete(selectedExercise: Exercise, hexFrame: CGRect)
    func didComplete()
}

class DotProgressView: UIView {
    
    // MARK: - Properties
    
    var currentStep: Int = 0
    var totalSteps: Int = 0
    private let dotSize: CGFloat = 14
    private let dotSpacing: CGFloat = 16
    private var completedColor: UIColor = .black
    private var remainingColor: UIColor = UIColor(hex: "#DDDDE1")
    private let trackHeight: CGFloat = 32
    private var sidePadding: CGFloat = 12
    
    // Progress layer for animation
    private var progressLayer: CALayer?
    private var backgroundLayer: CALayer?
    private var dotsLayer: CALayer?
    
    var delegate: DotProgressDelegate?
    
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
        
        // Create background track layer
        let bgLayer = CALayer()
        bgLayer.cornerRadius = trackHeight / 2
        bgLayer.backgroundColor = remainingColor.cgColor
        layer.addSublayer(bgLayer)
        backgroundLayer = bgLayer
        
        // Create progress layer
        let progLayer = CALayer()
        progLayer.cornerRadius = trackHeight / 2
        progLayer.backgroundColor = completedColor.cgColor
        layer.addSublayer(progLayer)
        progressLayer = progLayer
        
        // Create dots layer (will be populated in layoutSubviews)
        let dotsContainerLayer = CALayer()
        layer.addSublayer(dotsContainerLayer)
        dotsLayer = dotsContainerLayer
    }
    
    // MARK: - Public Methods
    
    /// Configure the progress view
    /// - Parameters:
    ///   - current: Current step (e.g., 7 for "7 of 9")
    ///   - total: Total steps (e.g., 9 for "7 of 9")
    ///   - completedColor: Color for completed dots and track
    ///   - remainingColor: Color for remaining dots and track
    ///   - sidePadding: Padding before first dot and after last dot
    func configure(current: Int,
                  total: Int,
                  completedColor: UIColor = .black,
                  sidePadding: CGFloat = 24) {
        self.currentStep = max(0, min(current, total))
        self.totalSteps = max(1, total)
        self.completedColor = completedColor
        self.sidePadding = sidePadding
        
        // Update colors
        backgroundLayer?.backgroundColor = remainingColor.cgColor
        progressLayer?.backgroundColor = completedColor.cgColor
        
        setNeedsLayout()
    }
    
    /// Returns the center of the dot before the one that will be filled by the next bump, converted to another view.
    func previousDotCenterForNextBump(convertedTo targetView: UIView) -> CGPoint {
        let nextStep = min(currentStep + 1, totalSteps)
        return dotCenter(at: max(0, nextStep - 2), convertedTo: targetView)
    }
    
    /// Returns the center of the dot that will be filled by the next bump, converted to another view.
    func nextDotCenterForNextBump(convertedTo targetView: UIView) -> CGPoint {
        let nextStep = min(currentStep + 1, totalSteps)
        return dotCenter(at: max(0, nextStep - 1), convertedTo: targetView)
    }
    
    /// Returns the center of the dot before the current filled step, converted to another view.
    func previousDotCenterForCurrentStep(convertedTo targetView: UIView) -> CGPoint {
        return dotCenter(at: max(0, currentStep - 2), convertedTo: targetView)
    }
    
    /// Returns the center of the current filled step, converted to another view.
    func currentDotCenter(convertedTo targetView: UIView) -> CGPoint {
        return dotCenter(at: max(0, currentStep - 1), convertedTo: targetView)
    }
    
    private func dotCenter(at dotIndex: Int, convertedTo targetView: UIView) -> CGPoint {
        layoutIfNeeded()
        let clampedIndex = max(0, min(dotIndex, totalSteps - 1))
        let dotsWidth = CGFloat(totalSteps) * dotSize + CGFloat(totalSteps - 1) * dotSpacing
        let startX = (bounds.width - dotsWidth) / 2
        let center = CGPoint(
            x: startX + CGFloat(clampedIndex) * (dotSize + dotSpacing) + dotSize / 2,
            y: bounds.height / 2
        )
        return convert(center, to: targetView)
    }
    
    /// Animates the transition to the next step with a bump animation
    func bump(after delaySeconds: TimeInterval = 0, onCompletion: @escaping (() -> ())) {
        // Calculate the next step (one step up)
        let nextStep = min(currentStep + 1, totalSteps)
        
        // If already at max, do nothing
        guard nextStep > currentStep else { return }
        
        let isDone = nextStep == totalSteps
        
        // Update the model
        currentStep = nextStep
        
        // Delay the animation by the specified amount
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
            let animationDuration = DotProgressAnimation.bumpDuration
            self.addProgressGrowShake(duration: animationDuration)
            
            // Animate the progress layer
            CATransaction.begin()
            CATransaction.setAnimationDuration(animationDuration)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
            
            // Update progress layer frame with animation
            if isDone {
                CATransaction.begin()
                CATransaction.setAnimationDuration(DotProgressAnimation.bumpDuration) // Animation duration in seconds
                let scale = DotProgressAnimation.completedScale
                self.progressLayer?.transform = CATransform3DMakeScale(scale, scale, scale)
                self.progressLayer?.backgroundColor = UIColor.akOrange.cgColor
                CATransaction.commit()
            }
            
            self.updateProgressLayerFrame()
            
            // Update dot colors
            self.updateDotLayers()
            
            CATransaction.commit()
            
            // Add haptic feedback
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator.impactOccurred()
            
            // Call completion handler after animation finishes
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                if isDone {
                    onCompletion()
                }
            }
        }
    }
    private func addProgressGrowShake(duration: TimeInterval) {
        guard let progressLayer = progressLayer else { return }
        progressLayer.removeAnimation(forKey: "progressGrowShake")
        
        let xShake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        xShake.values = DotProgressAnimation.shakeXValues
        xShake.keyTimes = DotProgressAnimation.shakeKeyTimes
        xShake.timingFunctions = Array(repeating: CAMediaTimingFunction(name: .easeInEaseOut), count: DotProgressAnimation.shakeKeyTimes.count - 1)
        
        let yShake = CAKeyframeAnimation(keyPath: "transform.translation.y")
        yShake.values = DotProgressAnimation.shakeYValues
        yShake.keyTimes = xShake.keyTimes
        yShake.timingFunctions = xShake.timingFunctions
        
        let shakeGroup = CAAnimationGroup()
        shakeGroup.animations = [xShake, yShake]
        shakeGroup.duration = duration
        shakeGroup.isRemovedOnCompletion = true
        progressLayer.add(shakeGroup, forKey: "progressGrowShake")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = bounds.width
        let height = bounds.height
        let centerY = height / 2
        
        // Calculate total width needed for all dots with padding
        let dotsWidth = CGFloat(totalSteps) * dotSize + CGFloat(totalSteps - 1) * dotSpacing
        
        // Center everything horizontally
        let startX = (width - dotsWidth) / 2
        
        // Update background track layer
        backgroundLayer?.frame = CGRect(
            x: startX - sidePadding,
            y: centerY - trackHeight/2,
            width: dotsWidth + (sidePadding * 2),
            height: trackHeight
        )
        
        // Update progress layer
        updateProgressLayerFrame(animated: false)
        
        // Update dots
        updateDotLayers()
    }
    
    private func updateProgressLayerFrame(animated: Bool = true) {
        let width = bounds.width
        let height = bounds.height
        let centerY = height / 2
        
        // Calculate total width needed for all dots with padding
        let dotsWidth = CGFloat(totalSteps) * dotSize + CGFloat(totalSteps - 1) * dotSpacing
        
        // Center everything horizontally
        let startX = (width - dotsWidth) / 2
        
        // Calculate completed width
        let completedWidth: CGFloat
        if currentStep <= 0 {
            completedWidth = 0
        } else if currentStep >= totalSteps {
            completedWidth = dotsWidth + (sidePadding * 2)
        } else {
            completedWidth = CGFloat(currentStep) * (dotSize + dotSpacing) - dotSpacing + sidePadding + 8
        }
        
        // Update progress layer
        progressLayer?.frame = CGRect(
            x: startX - sidePadding,
            y: centerY - trackHeight/2,
            width: completedWidth,
            height: trackHeight
        )
    }
    
    private func updateDotLayers() {
        guard let dotsLayer = dotsLayer else { return }
        
        // Remove existing dot layers
        dotsLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let width = bounds.width
        let height = bounds.height
        let centerY = height / 2
        
        // Calculate total width needed for all dots with padding
        let dotsWidth = CGFloat(totalSteps) * dotSize + CGFloat(totalSteps - 1) * dotSpacing
        
        // Center everything horizontally
        let startX = (width - dotsWidth) / 2
        
        // Create new dot layers
        for i in 0..<totalSteps {
            let dotX = startX + CGFloat(i) * (dotSize + dotSpacing)
            
            // Create dot layer
            let dotLayer = CAShapeLayer()
            let dotRect = CGRect(x: dotX, y: centerY - dotSize/2, width: dotSize, height: dotSize)
            let dotPath = UIBezierPath(ovalIn: dotRect).cgPath
            
            dotLayer.path = dotPath
            dotLayer.fillColor = UIColor.white.cgColor
            dotLayer.lineWidth = 2
            
            dotsLayer.addSublayer(dotLayer)
        }
    }
    
    // MARK: - Intrinsic Content Size
    
    override var intrinsicContentSize: CGSize {
        let dotsWidth = CGFloat(totalSteps) * dotSize + CGFloat(totalSteps - 1) * dotSpacing
        let width = dotsWidth + (sidePadding * 2)
        return CGSize(width: width, height: trackHeight * 1.5)
    }
}
