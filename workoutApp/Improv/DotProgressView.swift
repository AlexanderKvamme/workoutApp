import UIKit

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
    private var remainingColor: UIColor = .black.withAlphaComponent(0.1)
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
    
    /// Animates the transition to the next step with a bump animation
    func bump(onCompletion: @escaping (() -> ())) {
        // Calculate the next step (one step up)
        let nextStep = min(currentStep + 1, totalSteps)
        
        // If already at max, do nothing
        guard nextStep > currentStep else { return }
        
        // Update the model
        currentStep = nextStep
        
        let animationDuration = 0.3
        // Animate the progress layer
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
        
        // Update progress layer frame with animation
        updateProgressLayerFrame()
        
        // Update dot colors
        updateDotLayers()
        
        CATransaction.commit()
        
        // Add haptic feedback
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            if self.currentStep == self.totalSteps {
                onCompletion()
//                self.delegate?.didComplete()
            }
        }
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
