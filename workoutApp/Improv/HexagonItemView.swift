import AKKIT
import UIKit

// MARK: - HexagonItemView
class HexagonItemView<T>: UIView {
    
    // MARK: - Properties
    
    private var hexagonLayer: CAShapeLayer?
    var textLabel = UILabel()
    
    // Stripes view
    private var stripesView: StripesView?
    
    // Dots view
    private var dotsView: DotsView?
    
    // Long press properties
    private let longPressDuration: TimeInterval = 1.0
    private var progressShapeLayer: CAShapeLayer?
    private var animationStartTime: CFTimeInterval?
    private var displayLink: CADisplayLink?
    private var completionHandler: (() -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hexPath = HexagonPathCreator.createHexagonPath(in: bounds)
        return hexPath.contains(point)
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        // Create hexagon shape
        let hexagonLayer = CAShapeLayer()
        hexagonLayer.path = HexagonPathCreator.createHexagonPath(in: bounds).cgPath
        hexagonLayer.fillColor = UIColor.red.cgColor
        layer.addSublayer(hexagonLayer)
        self.hexagonLayer = hexagonLayer
        
        // Add text label
        let textLabel = UILabel()
        textLabel.frame = bounds.insetBy(dx: bounds.width * 0.15, dy: bounds.height * 0.15)
        textLabel.textAlignment = .center
        textLabel.font = AKFont.round(.black, 16)
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.35
        textLabel.textColor = .akLight
        addSubview(textLabel)
        self.textLabel = textLabel
        
        // Setup stripes view
        configureStripes(count: 0, color: .purple)
        
        // Setup dots view (after other views are set up)
        setupDotsView()
    }
    
    private func setupDotsView() {
        // Remove any existing dots view
        dotsView?.removeFromSuperview()
        
        // Create dots view
        let newDotsView = DotsView(frame: bounds)
        addSubview(newDotsView) // Add as a direct subview
        dotsView = newDotsView
        dotsView!.transform = dotsView!.transform.rotated(by: 4*Double.pi/3)
        dotsView?.alpha = 0.5
        
        // Make sure dots view fills the bounds
        newDotsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newDotsView.topAnchor.constraint(equalTo: topAnchor),
            newDotsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            newDotsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            newDotsView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Configure initial dots (optional)
        newDotsView.configureDots(count: 0, size: 8.0, spacing: 5.0, color: .white)
        
        // Bring text label to front to ensure it's visible
        bringSubviewToFront(textLabel)
    }
    
    func configure(withMuscle muscle: Muscle) {
        configure(name: muscle.getName(), lastPerformanceDate: muscle.lastPerformance())
    }
    
    func configure(withSkill skill: Skill) {
        configure(name: skill.getName(), lastPerformanceDate: skill.lastPerformance())
    }
    
    func configure(name: String, lastPerformanceDate: Date?) {
        print("Last performance date: ", lastPerformanceDate)
        setText(name)
        
        let colors: [UIColor] = [
            UIColor.white,         // 0-3 days (very recent)
            UIColor.akLightGray,   // 4-7 days
            UIColor.akGray,        // 8-13 days
            UIColor.black          // 14+ days (needs attention)
        ]
        
        let daysSincePerformance = lastPerformanceDate?.daysSinceNow() ?? Int.max
        
        // Select color based on days since last performance
        let selectedColor: UIColor
        if daysSincePerformance >= 14 {
            selectedColor = colors[3]  // black (14+ days)
        } else if daysSincePerformance >= 8 {
            selectedColor = colors[2]  // dark gray (8-13 days)
        } else if daysSincePerformance >= 4 {
            selectedColor = colors[1]  // light gray (4-7 days)
        } else {
            selectedColor = colors[0]  // white (0-3 days)
        }
        
        // Apply the selected color
        self.hexagonLayer?.fillColor = selectedColor.cgColor
        
        // Adjust text color for readability
        if selectedColor == UIColor.white {
            textLabel.textColor = UIColor.akLightGray
        } else {
            textLabel.textColor = UIColor.white
        }
    }
    
    func configure(withExercise exercise: Exercise, andLog log: WorkoutLog?, inverted: Bool = false) {
        isUserInteractionEnabled = true
        alpha = 1.0
        var textColor = inverted ? UIColor.white : UIColor.black
        self.hexagonLayer?.fillColor = (inverted ? UIColor.black : UIColor.white).cgColor

        if let log = log {
            let sets = log.loggedExercises?.array as! [ExerciseLog]
            let filteredSets = sets.filter { $0.getName() == exercise.getName() }
            
            let progressiveColors = inverted ? [
                    UIColor.black,
                    UIColor.akDarkGray,
                    UIColor.akGray,
                    UIColor.akLightGray,
                    UIColor.white
                ] : [
                    UIColor.white,         // 0-3 days (very recent)
                    UIColor.akLightGray,   // 4-7 days
                    UIColor.akGray,        // 8-13 days
                    UIColor.akDarkGray,
                    UIColor.black          // 14+ days (needs attention)
                ]
            
            let count = filteredSets.count
            if count > 0 {
                textColor = inverted && count >= progressiveColors.count - 1 ? .black : .white
            }
            
            if count >= progressiveColors.count {
                self.hexagonLayer?.fillColor = progressiveColors.last?.cgColor
            } else {
                self.hexagonLayer?.fillColor = progressiveColors[count].cgColor
            }
        } else {
            print("❌ no workout log")
        }

        setText(exercise.name ?? "")
        textLabel.textColor = textColor
    }
    
    func configureDisabledWorkoutAppearance() {
        isUserInteractionEnabled = false
        alpha = 1.0
        hexagonLayer?.fillColor = UIColor.white.cgColor
        textLabel.textColor = UIColor(hex: "#DDDDE1")
    }

    // MARK: - Public Methods
    
    func configure(withItem item: T, log: WorkoutLog?) {
        if let item = item as? Muscle {
            configure(withMuscle: item)
        } else if let item = item as? Skill {
            configure(withSkill: item)
        } else if let item = item as? Exercise {
            print("configuring exercise cell: ", item.name)
            configure(withExercise: item, andLog: log)
        } else {
            setText("not muscle")
        }
    }
    
    private func setText(_ text: String) {
        textLabel.text = text
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.adjustsFontSizeToFitWidth = true
        
        // Multi-line UILabel scaling is limited, so do a small manual pass too.
        // This keeps long names readable and avoids breaking words in the middle
        // unless a single word is physically too wide for the hexagon.
        let availableSize = textLabel.bounds.size == .zero
            ? bounds.insetBy(dx: bounds.width * 0.15, dy: bounds.height * 0.15).size
            : textLabel.bounds.size
        
        for fontSize in stride(from: CGFloat(16), through: CGFloat(11), by: CGFloat(-1)) {
            let font = AKFont.round(.black, fontSize)
            let boundingSize = CGSize(width: availableSize.width, height: CGFloat.greatestFiniteMagnitude)
            let textRect = (text as NSString).boundingRect(
                with: boundingSize,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: font],
                context: nil
            )
            
            if textRect.height <= availableSize.height {
                textLabel.font = font
                return
            }
        }
        
        textLabel.font = AKFont.round(.black, 11)
    }
    
    // MARK: - Stripes Methods
    
    func configureStripes(count: Int,
                          color: UIColor = UIColor.green,
                          width: CGFloat = 10.0,
                          spacing: CGFloat = 16.0,
                          angle: CGFloat = .pi / 4,
                          inset: CGFloat = 0.2) {
        
        // Remove existing stripes view if any
        stripesView?.removeFromSuperview()
        
        // Create a new stripes view
        let newStripesView = StripesView(frame: bounds)
        newStripesView.configureStripes(
            count: count,
            width: width,
            spacing: spacing,
            angle: angle,
            inset: inset
        )
        
        // Add to view hierarchy
        insertSubview(newStripesView, at: 1) // Insert above hexagon layer but below text
        stripesView = newStripesView
        
        // Make sure stripes view fills the bounds
        newStripesView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newStripesView.topAnchor.constraint(equalTo: topAnchor),
            newStripesView.leadingAnchor.constraint(equalTo: leadingAnchor),
            newStripesView.trailingAnchor.constraint(equalTo: trailingAnchor),
            newStripesView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// Bump the stripes
    func bumpStripes(completion: (() -> Void)? = nil) {
        stripesView?.bumpStripes()
    }
    
    // MARK: - Dots Methods
    
    /// Bump the dots (add one more dot)
    /// - Parameters:
    ///   - color: Optional color for the dots
    ///   - completion: Optional completion handler
    func bumpDots(color: UIColor? = nil, completion: (() -> Void)? = nil) {
        if dotsView == nil {
            print("DotsView is nil, setting up...")
            setupDotsView()
        }
        dotsView?.bumpDots(color: color, completion: completion)
    }

    /// Reset dots when needed
    func resetDots(animated: Bool = true) {
        dotsView?.resetDots(animated: animated)
    }

    /// Configure dots
    func configureDots(count: Int = 0,
                      size: CGFloat = 8.0,
                      spacing: CGFloat = 5.0,
                      color: UIColor = .white) {
        dotsView?.configureDots(count: count, size: size, spacing: spacing, color: color)
    }
    
    // MARK: - Long Press Handling
    
    /// Set the action to be performed when long press completes
    func setLongPressAction(_ completion: @escaping () -> Void) {
        completionHandler = completion
    }
    
    func startLongPressAnimation() {
        // Cancel any existing animation
        cancelLongPressAnimation()
        
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
        
        // Update the fill opacity based on progress
        progressLayer.opacity = Float(progress)
        
        // Check if animation is complete
        if progress >= 1.0 {
            completeAction()
        }
    }
    
    func cancelLongPressAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        animationStartTime = nil
        
        // Fade out the fill with animation
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        progressShapeLayer?.opacity = 0
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
        
        // Reset the progress layer with animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.3)
            self?.progressShapeLayer?.opacity = 0
            CATransaction.commit()
        }
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update hexagon layer path
        if let hexagonLayer = hexagonLayer {
            hexagonLayer.path = HexagonPathCreator.createHexagonPath(in: bounds).cgPath
        }
        
        // Update text label frame
        textLabel.frame = bounds.insetBy(dx: bounds.width * 0.15, dy: bounds.height * 0.15)
        
        // Update progress layer if needed
        if let progressShapeLayer = progressShapeLayer {
            progressShapeLayer.path = HexagonPathCreator.createHexagonPath(in: bounds).cgPath
        }
    }
    
    // MARK: - Helper Methods
    
    private func createHexagonPath() -> UIBezierPath {
        let size = bounds.width
        let path = UIBezierPath()
        let center = CGPoint(x: size/2, y: size/2)
        let radius = size/2 - 2
        let cornerRadius: CGFloat = 10
        let cornerInset = cornerRadius
        
        // Calculate points of the hexagon
        var points: [CGPoint] = []
        for i in 0..<6 {
            let angle = CGFloat(i) * (CGFloat.pi / 3)
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            points.append(point)
        }
        
        // Create a hexagon with rounded corners
        for i in 0..<6 {
            let currentPoint = points[i]
            let nextPoint = points[(i + 1) % 6]
            
            // Calculate direction vectors
            let dx1 = currentPoint.x - points[(i + 5) % 6].x
            let dy1 = currentPoint.y - points[(i + 5) % 6].y
            let len1 = sqrt(dx1*dx1 + dy1*dy1)
            
            let dx2 = nextPoint.x - currentPoint.x
            let dy2 = nextPoint.y - currentPoint.y
            let len2 = sqrt(dx2*dx2 + dy2*dy2)
            
            // Inset points from the vertex
            let insetPoint1 = CGPoint(
                x: currentPoint.x - (dx1 / len1) * cornerInset,
                y: currentPoint.y - (dy1 / len1) * cornerInset
            )
            
            let insetPoint2 = CGPoint(
                x: currentPoint.x + (dx2 / len2) * cornerInset,
                y: currentPoint.y + (dy2 / len2) * cornerInset
            )
            
            // First point or continuing the path
            if i == 0 {
                path.move(to: insetPoint1)
            } else {
                path.addLine(to: insetPoint1)
            }
            
            // Add the rounded corner
            path.addQuadCurve(to: insetPoint2, controlPoint: currentPoint)
            
            // Add the straight line to the next corner
            if i < 5 {
                path.addLine(to: CGPoint(
                    x: nextPoint.x - (dx2 / len2) * cornerInset,
                    y: nextPoint.y - (dy2 / len2) * cornerInset
                ))
            }
        }
        
        path.close()
        return path
    }
}
