import UIKit

class DotProgressView: UIView {
    
    // MARK: - Properties
    
    private var currentStep: Int = 0
    private var totalSteps: Int = 0
    private let dotSize: CGFloat = 14
    private let dotSpacing: CGFloat = 16
    private var completedColor: UIColor = .black
    private var remainingColor: UIColor = .lightGray
    private let trackHeight: CGFloat = 32
    private var sidePadding: CGFloat = 24  // Padding before first dot and after last dot
    
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
                  remainingColor: UIColor = .lightGray,
                  sidePadding: CGFloat = 24) {
        self.currentStep = max(0, min(current, total))
        self.totalSteps = max(1, total)
        self.completedColor = completedColor
        self.remainingColor = remainingColor
        self.sidePadding = sidePadding
        setNeedsDisplay()
    }
    
    /// Animates the transition to the next step with a bump animation
    func bump() {
        // Calculate the next step (one step up)
        let nextStep = min(currentStep + 1, totalSteps)
        
        // If already at max, do nothing
        guard nextStep > currentStep else { return }
        
        // Update the model
        currentStep = nextStep
        
        // Redraw with animation
        UIView.animate(withDuration: 0.2) {
            self.setNeedsDisplay()
        }
        
        // Add haptic feedback
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), totalSteps > 0 else { return }
        
        let width = rect.width
        let height = rect.height
        let centerY = height / 2
        
        // Calculate total width needed for all dots with padding
        let dotsWidth = CGFloat(totalSteps) * dotSize + CGFloat(totalSteps - 1) * dotSpacing
        let totalWidth = dotsWidth + (sidePadding * 2)
        
        // Center everything horizontally
        let startX = (width - dotsWidth) / 2
        
        // Draw the track background
        let trackPath = UIBezierPath(roundedRect: CGRect(
            x: startX - sidePadding,
            y: centerY - trackHeight/2,
            width: dotsWidth + (sidePadding * 2),
            height: trackHeight),
            cornerRadius: trackHeight/2)
        remainingColor.setFill()
        trackPath.fill()
        
        // Draw the completed portion of the track
        if currentStep > 0 {
            let lastStep = currentStep == totalSteps
            let endingExtraLength = lastStep ? sidePadding : 0
            let completedWidth = CGFloat(currentStep) * (dotSize + dotSpacing) - 2*dotSpacing + endingExtraLength
            let completedTrackPath = UIBezierPath(roundedRect: CGRect(
                x: startX - sidePadding,
                y: centerY - trackHeight/2,
                width: completedWidth + (sidePadding * 2),
                height: trackHeight),
                cornerRadius: trackHeight/2)
            completedColor.setFill()
            completedTrackPath.fill()
        }
        
        // Draw the dots
        for i in 0..<totalSteps {
            let dotX = startX + CGFloat(i) * (dotSize + dotSpacing)
            let dotRect = CGRect(x: dotX, y: centerY - dotSize/2, width: dotSize, height: dotSize)
            let dotPath = UIBezierPath(ovalIn: dotRect)
            
            // Use white color for dots to make them stand out from the track
            UIColor.white.setFill()
            dotPath.fill()
            
            // Add border to dots
            let borderColor = i < currentStep ? completedColor : remainingColor
            borderColor.setStroke()
            dotPath.stroke()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let dotsWidth = CGFloat(totalSteps) * dotSize + CGFloat(totalSteps - 1) * dotSpacing
        let width = dotsWidth + (sidePadding * 2)
        return CGSize(width: width, height: trackHeight * 1.5)
    }
}
