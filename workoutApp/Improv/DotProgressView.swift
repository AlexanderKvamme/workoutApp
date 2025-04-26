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
        layer.cornerRadius = trackHeight / 2
        clipsToBounds = true
    }
    
    // MARK: - Public Methods
    
    /// Configure the progress view
    /// - Parameters:
    ///   - current: Current step (e.g., 7 for "7 of 9")
    ///   - total: Total steps (e.g., 9 for "7 of 9")
    ///   - completedColor: Color for completed dots and track
    ///   - remainingColor: Color for remaining dots and track
    func configure(current: Int, total: Int, completedColor: UIColor = .black, remainingColor: UIColor = .lightGray) {
        self.currentStep = max(0, min(current, total))
        self.totalSteps = max(1, total)
        self.completedColor = completedColor
        self.remainingColor = remainingColor
        setNeedsDisplay()
    }
    
    /// Animates the transition to the next step with a bump animation
    func bump() {
        // Calculate the next step (one step up)
        let nextStep = min(currentStep + 1, totalSteps)
        
        // If already at max, do nothing
        guard nextStep > currentStep else { return }
        
        // Get the dot that will be bumped
        let dotIndex = nextStep - 1
        let width = bounds.width
        let totalDotsWidth = CGFloat(totalSteps) * dotSize
        let totalSpacingWidth = CGFloat(totalSteps - 1) * dotSpacing
        let totalWidth = totalDotsWidth + totalSpacingWidth
        let startX = (width - totalWidth) / 2
        let dotX = startX + CGFloat(dotIndex) * (dotSize + dotSpacing)
        let dotCenter = CGPoint(x: dotX + dotSize/2, y: bounds.height/2)
        let centerY = bounds.height / 2
        
        // Create a temporary view for the dot animation
        let animatedDot = UIView(frame: CGRect(x: 0, y: 0, width: dotSize, height: dotSize))
        animatedDot.backgroundColor = UIColor.white
        animatedDot.layer.borderColor = UIColor.white.cgColor
        animatedDot.layer.borderWidth = 5
        animatedDot.layer.cornerRadius = dotSize/2
        animatedDot.center = dotCenter
        addSubview(animatedDot)
        
        // Create a black progress bar for animation
        let progressBar = UIView(frame: CGRect(
            x: startX - dotSize/2,
            y: centerY - trackHeight/2,
            width: currentStep > 0 ? (CGFloat(currentStep - 1) * (dotSize + dotSpacing) + dotSize) : 0,
            height: trackHeight
        ))
        progressBar.backgroundColor = completedColor
        progressBar.layer.cornerRadius = trackHeight/2
        insertSubview(progressBar, at: 0)
        
        // Calculate the final width for the progress bar
        let finalWidth = CGFloat(nextStep - 1) * (dotSize + dotSpacing) + dotSize + dotSpacing
        
        // Update the model
        currentStep = nextStep
        
        // Animation duration
        let duration: TimeInterval = 0.2
        
        UIView.animate(withDuration: duration) {
            progressBar.frame = CGRect(
                x: startX - self.dotSize/2,
                y: centerY - self.trackHeight/2,
                width: finalWidth,
                height: self.trackHeight
            )
        }
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), totalSteps > 0 else { return }
        
        let width = rect.width
        let height = rect.height
        
        // Calculate total width needed for all dots
        let totalDotsWidth = CGFloat(totalSteps) * dotSize
        let totalSpacingWidth = CGFloat(totalSteps - 1) * dotSpacing
        let totalWidth = totalDotsWidth + totalSpacingWidth
        
        // Center everything horizontally
        let startX = (width - totalWidth) / 2
        let centerY = height / 2
        
        // Draw the track background
        let trackPath = UIBezierPath(roundedRect: CGRect(x: startX - dotSize/2, y: centerY - trackHeight/2,
                                                        width: totalWidth + dotSize, height: trackHeight),
                                    cornerRadius: trackHeight/2)
        remainingColor.setFill()
        trackPath.fill()
        
        // Draw the completed portion of the track
        if currentStep > 0 {
            let completedWidth = startX - dotSize/2 + CGFloat(currentStep - 1) * (dotSize + dotSpacing) + dotSize
            let completedTrackPath = UIBezierPath(roundedRect: CGRect(x: startX - dotSize/2, y: centerY - trackHeight/2,
                                                                     width: completedWidth, height: trackHeight),
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
        let totalDotsWidth = CGFloat(totalSteps) * dotSize
        let totalSpacingWidth = CGFloat(totalSteps - 1) * dotSpacing
        let width = totalDotsWidth + totalSpacingWidth + dotSize * 2  // Extra padding
        return CGSize(width: width, height: max(dotSize * 2, trackHeight * 3))
    }
}
