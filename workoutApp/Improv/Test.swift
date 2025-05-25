//
//  AnimatedTextView.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 24/05/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT
import Lottie
import SnapKit
import VFont

// MARK: - AnimatedTextView
class AnimatedTextView: UIView {
    
    // MARK: - Properties
    private var charLabels: [UILabel] = []
    private var originalText: String = ""
    private var textFont: UIFont
    private var textColor: UIColor
    private var randomColorIndices: [Int] = []
    private var flashPercentage: Int
    
    // Extra padding to prevent clipping
    private let horizontalPadding: CGFloat = 0
    private let verticalPadding: CGFloat = 0
    
    // Animation state tracking
    private var labelColors: [Int: UIColor] = [:]
    private var colorAnimators: [Int: ColorAnimator] = [:]
    private var fontAnimators: [Int: FontWeightAnimator] = [:]
    
    // MARK: - Initialization
    init(text: String, font: UIFont, color: UIColor, flashPercentage: Int = 100) {
        self.originalText = text
        self.textFont = font
        self.textColor = color
        self.flashPercentage = flashPercentage
        super.init(frame: .zero)
        backgroundColor = .clear
        prepareAnimation()
    }
    
    required init?(coder: NSCoder) {
        self.textFont = UIFont.systemFont(ofSize: 48, weight: .black)
        self.textColor = .black
        self.flashPercentage = 100
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLabelsLayout()
    }
    
    // MARK: - Public Methods
    func configure(text: String, font: UIFont, color: UIColor) {
        // Clear any existing animation
        cleanup()
        
        originalText = text
        textFont = font
        textColor = color
        
        prepareAnimation()
        updateLabelsLayout()
    }
    
    func animate(completion: (() -> Void)? = nil) {
        // Reset animation state
        labelColors.removeAll()
        
        // Stop any existing animators
        for animator in colorAnimators.values {
            animator.stop()
        }
        colorAnimators.removeAll()
        
        for animator in fontAnimators.values {
            animator.stop()
        }
        fontAnimators.removeAll()
        
        // Animate each character
        for (i, label) in charLabels.enumerated() {
            // Set initial state
            let scale = 0.6
            label.alpha = 0
            label.textColor = textColor
            label.transform = label.transform.scaledBy(x: scale, y: scale)
            
            // Store initial color
            labelColors[i] = textColor
            
            // Use CAKeyframeAnimation for smoother Y position animation
            let positionAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
            positionAnimation.values = [50.0, -25.0, 0.0]  // Start offset, overshoot, final position
            positionAnimation.timingFunctions = [
                CAMediaTimingFunction(name: .easeOut),
                CAMediaTimingFunction(name: .easeInEaseOut)
            ]
            positionAnimation.keyTimes = [0.0, 0.4, 1.0]
            positionAnimation.duration = 0.8
            positionAnimation.beginTime = CACurrentMediaTime() + Double(i) * 0.05
            positionAnimation.fillMode = .forwards
            positionAnimation.isRemovedOnCompletion = false
            label.layer.add(positionAnimation, forKey: "positionAnimation")
            
            // Scale animation
            let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            scaleAnimation.values = [0.5, 1.025, 1.0]  // Start small, overshoot (pop), final size
            scaleAnimation.timingFunctions = [
                CAMediaTimingFunction(name: .easeOut),
                CAMediaTimingFunction(name: .easeInEaseOut)
            ]
            scaleAnimation.keyTimes = [0.0, 0.4, 1.0]  // Match timing with position animation
            scaleAnimation.duration = 0.8
            scaleAnimation.beginTime = CACurrentMediaTime() + Double(i) * 0.05  // Same delay as position
            scaleAnimation.fillMode = .forwards
            scaleAnimation.isRemovedOnCompletion = false
            label.layer.add(scaleAnimation, forKey: "scaleAnimation")
            
            // Rotation animation
            let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.values = [Double.pi * -0.1, Double.pi * 0.05, 0.0]  // Slight rotation in radians
            rotationAnimation.timingFunctions = [
                CAMediaTimingFunction(name: .easeOut),
                CAMediaTimingFunction(name: .easeInEaseOut)
            ]
            rotationAnimation.keyTimes = [0.0, 0.5, 1.0]  // Match timing with other animations
            rotationAnimation.duration = 0.8
            rotationAnimation.beginTime = CACurrentMediaTime() + Double(i) * 0.05  // Same delay as others
            rotationAnimation.fillMode = .forwards
            rotationAnimation.isRemovedOnCompletion = false
            label.layer.add(rotationAnimation, forKey: "rotationAnimation")
            
            // Fade in and scale with a simple animation
            UIView.animate(withDuration: 0.2, delay: Double(i) * 0.05, options: .curveLinear, animations: {
                label.alpha = 1.0
                label.transform = .identity
            }, completion: { _ in
                // Call completion handler after the last character finishes
                if i == self.charLabels.count - 1 {
                    // Wait for the animation to complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        // Reset the animation state but keep the labels visible
                        for label in self.charLabels {
                            label.layer.removeAllAnimations()
                            label.transform = .identity
                            label.textColor = self.textColor
                        }
                        
                        // Stop all animators
                        for animator in self.colorAnimators.values {
                            animator.stop()
                        }
                        self.colorAnimators.removeAll()
                        
                        for animator in self.fontAnimators.values {
                            animator.stop()
                        }
                        self.fontAnimators.removeAll()
                        
                        completion?()
                    }
                }
            })
            
            // Determine if this character should have color animation
            let shouldFlashColor = Int.random(in: 0...100) >= (100-flashPercentage)
            
            // Animate font weight and color together
            animateFontWeightAndColor(for: label, index: i, duration: 0.8, delay: Double(i) * 0.05, flashColor: shouldFlashColor)
        }
    }
    
    // MARK: - Private Methods
    private func animateFontWeightAndColor(for label: UILabel, index: Int, duration: TimeInterval, delay: TimeInterval = 0, flashColor: Bool) {
        // Get the variable font
        let vfont = VFonts.elza(size: textFont.pointSize)
        
        // Create timing for font weight animation
        let fontStartTime = delay + duration * 0.1  // Start font animation at 10% of total animation
        let fontDuration = duration * 0.6           // Font animation duration is 60% of total animation
        
        // Create and start the font weight animator
        let fontAnimator = FontWeightAnimator(
            label: label,
            vfont: vfont,
            startWeight: 0.0,
            endWeight: 1.0,
            startDelay: fontStartTime,
            duration: fontDuration
        )
        
        fontAnimators[index] = fontAnimator
        fontAnimator.start()
        
        // Animate color if needed
        if flashColor {
            let randomColor = CONFETTI_COLORS.randomElement()!
            
            // Create timing for color animation
            let flashStartTime = delay + duration * 0.3  // Start flash at 30% of animation
            let flashDuration = duration * 0.3           // Flash duration is 30% of total animation
            let fadeOutDuration = duration * 0.2         // Fade out is 20% of total animation
            
            // Create and start the color animator
            let colorAnimator = ColorAnimator(
                label: label,
                fromColor: textColor,
                toColor: randomColor,
                startDelay: flashStartTime,
                duration: flashDuration,
                fadeOutDuration: fadeOutDuration
            )
            
            colorAnimators[index] = colorAnimator
            colorAnimator.start()
        }
    }
    
    private func prepareAnimation() {
        guard !originalText.isEmpty else { return }
        
        // Create a label for each character
        for char in originalText {
            let label = UILabel()
            label.text = String(char)
            label.font = textFont
            label.textColor = textColor
            label.textAlignment = .center
            label.alpha = 0
            
            // Prevent clipping
            label.clipsToBounds = false
            
            // Add padding to the label
            label.frame.size = calculateSizeForCharacter(char, with: textFont)
            
            // For smoother animation
            label.layer.allowsEdgeAntialiasing = true
            
            addSubview(label)
            charLabels.append(label)
        }
    }
    
    private func calculateSizeForCharacter(_ char: Character, with font: UIFont) -> CGSize {
        // Calculate the base size
        let charString = String(char)
        let attributes = [NSAttributedString.Key.font: font]
        var size = (charString as NSString).boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        ).size
        
        // Pre-calculate the maximum size with bold font
        let vfont = VFonts.elza(size: font.pointSize)
        let boldFont = vfont.make(weight: 1.0)
        let boldAttributes = [NSAttributedString.Key.font: boldFont]
        let boldSize = (charString as NSString).boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: boldAttributes,
            context: nil
        ).size
        
        // Use the larger of the two sizes
        size.width = max(size.width, boldSize.width)
        size.height = max(size.height, boldSize.height)
        
        // Add padding
        size.width += horizontalPadding
        size.height += verticalPadding
        
        return size
    }
    
    private func updateLabelsLayout() {
        guard !charLabels.isEmpty else { return }
        
        // Calculate total width needed for all characters
        var totalWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for label in charLabels {
            totalWidth += label.frame.width
            maxHeight = max(maxHeight, label.frame.height)
        }
        
        // Position each label with kerning adjustments
        var currentX: CGFloat = (bounds.width - totalWidth) / 2
        var previousChar: Character? = nil
        
        for (i, label) in charLabels.enumerated() {
            // Apply kerning adjustment based on character pairs
            if i > 0, let prev = previousChar {
                let current = originalText[originalText.index(originalText.startIndex, offsetBy: i)]
                let kerningAdjustment = getKerningAdjustment(prevChar: prev, currentChar: current)
                currentX += kerningAdjustment
            }
            
            label.frame = CGRect(
                x: currentX,
                y: (bounds.height - maxHeight) / 2,
                width: label.frame.width,
                height: maxHeight
            )
            
            currentX += label.frame.width
            
            // Store current character for next iteration
            if i < originalText.count {
                previousChar = originalText[originalText.index(originalText.startIndex, offsetBy: i)]
            }
        }
        
        // Set the intrinsic content size
        invalidateIntrinsicContentSize()
    }
    
    private func getKerningAdjustment(prevChar: Character, currentChar: Character) -> CGFloat {
        // Adjust kerning for specific character pairs
        let pair = "\(prevChar)\(currentChar)"
        return 0
        
        switch pair {
        case "GO", "GG":
            return -8  // Reduce space between G and O or G and G
        case "IG", "FG":
            return -5  // Reduce space between I and G or F and G
        default:
            return 0   // No adjustment for other pairs
        }
    }
    
    override var intrinsicContentSize: CGSize {
        guard !charLabels.isEmpty else { return CGSize(width: 100, height: 50) }
        
        // Calculate total width and max height
        var totalWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for label in charLabels {
            totalWidth += label.frame.width
            maxHeight = max(maxHeight, label.frame.height)
        }
        
        return CGSize(width: totalWidth, height: maxHeight)
    }
    
    private func cleanup() {
        // Stop all animators
        for animator in colorAnimators.values {
            animator.stop()
        }
        colorAnimators.removeAll()
        
        for animator in fontAnimators.values {
            animator.stop()
        }
        fontAnimators.removeAll()
        
        // Remove all existing character labels
        for view in charLabels {
            view.removeFromSuperview()
        }
        charLabels.removeAll()
        randomColorIndices.removeAll()
        labelColors.removeAll()
    }
    
    deinit {
        cleanup()
    }
}

// MARK: - ColorAnimator
class ColorAnimator {
    private weak var label: UILabel?
    private let fromColor: UIColor
    private let toColor: UIColor
    private let startTime: TimeInterval
    private let duration: TimeInterval
    private let fadeOutDuration: TimeInterval
    
    private var displayLink: CADisplayLink?
    private var startTimestamp: TimeInterval = 0
    
    init(label: UILabel, fromColor: UIColor, toColor: UIColor, startDelay: TimeInterval, duration: TimeInterval, fadeOutDuration: TimeInterval) {
        self.label = label
        self.fromColor = fromColor
        self.toColor = toColor
        self.startTime = startDelay
        self.duration = duration
        self.fadeOutDuration = fadeOutDuration
    }
    
    func start() {
        // Create a display link
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func update(_ displayLink: CADisplayLink) {
        guard let label = label else {
            stop()
            return
        }
        
        // Initialize start timestamp on first frame
        if startTimestamp == 0 {
            startTimestamp = CACurrentMediaTime()
        }
        
        let currentTime = CACurrentMediaTime() - startTimestamp
        
        // Wait until start time
        if currentTime < startTime {
            return
        }
        
        // Calculate progress for fade in
        let fadeInProgress = min(1.0, max(0.0, (currentTime - startTime) / duration))
        
        // Calculate progress for fade out
        let fadeOutStartTime = startTime + duration
        let fadeOutProgress = min(1.0, max(0.0, (currentTime - fadeOutStartTime) / fadeOutDuration))
        
        // Determine the current color
        if fadeOutProgress > 0 {
            // We're in the fade out phase
            label.textColor = interpolateColor(from: toColor, to: fromColor, progress: fadeOutProgress)
            
            // Stop the animator when fade out is complete
            if fadeOutProgress >= 1.0 {
                stop()
            }
        } else {
            // We're in the fade in phase
            label.textColor = interpolateColor(from: fromColor, to: toColor, progress: fadeInProgress)
        }
    }
    
    private func interpolateColor(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
        var fromR: CGFloat = 0, fromG: CGFloat = 0, fromB: CGFloat = 0, fromA: CGFloat = 0
        var toR: CGFloat = 0, toG: CGFloat = 0, toB: CGFloat = 0, toA: CGFloat = 0
        
        from.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
        to.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)
        
        let r = fromR + (toR - fromR) * progress
        let g = fromG + (toG - fromG) * progress
        let b = fromB + (toB - fromB) * progress
        let a = fromA + (toA - fromA) * progress
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

// MARK: - FontWeightAnimator
class FontWeightAnimator {
    private weak var label: UILabel?
    private let vfont: VFont
    private let startWeight: CGFloat
    private let endWeight: CGFloat
    private let startTime: TimeInterval
    private let duration: TimeInterval
    
    private var displayLink: CADisplayLink?
    private var startTimestamp: TimeInterval = 0
    
    init(label: UILabel, vfont: VFont, startWeight: CGFloat, endWeight: CGFloat, startDelay: TimeInterval, duration: TimeInterval) {
        self.label = label
        self.vfont = vfont
        self.startWeight = startWeight
        self.endWeight = endWeight
        self.startTime = startDelay
        self.duration = duration
    }
    
    func start() {
        // Create a display link
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func update(_ displayLink: CADisplayLink) {
        guard let label = label else {
            stop()
            return
        }
        
        // Initialize start timestamp on first frame
        if startTimestamp == 0 {
            startTimestamp = CACurrentMediaTime()
        }
        
        let currentTime = CACurrentMediaTime() - startTimestamp
        
        // Wait until start time
        if currentTime < startTime {
            return
        }
        
        // Calculate progress
        let progress = min(1.0, max(0.0, (currentTime - startTime) / duration))
        
        // Apply easing function for smoother animation
        let easedProgress = easeInOutCubic(progress)
        
        // Interpolate weight
        let weight = startWeight + (endWeight - startWeight) * easedProgress
        
        // Update font with new weight
        label.font = vfont.make(weight: weight)
        
        // Stop the animator when animation is complete
        if progress >= 1.0 {
            stop()
        }
    }
    
    // Cubic easing function for smoother animation
    private func easeInOutCubic(_ x: CGFloat) -> CGFloat {
        return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2
    }
}
