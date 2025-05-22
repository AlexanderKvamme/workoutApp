//
//  HexCompletionScreen.swift
//
//  HexCompletionScreen.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 04/05/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT
import Lottie
import SnapKit

// MARK: - AnimatableLabel
class AnimatableLabel: UILabel {
    // Override the layer class to use CATextLayer
    override class var layerClass: AnyClass {
        return CATextLayer.self
    }
    
    // Configure the text layer
    private var textLayer: CATextLayer {
        return layer as! CATextLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextLayer()
    }
    
    private func setupTextLayer() {
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = .center
        textLayer.isWrapped = false
    }
    
    override var text: String? {
        didSet {
            textLayer.string = text
        }
    }
    
    override var font: UIFont! {
        didSet {
            textLayer.font = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
            textLayer.fontSize = font.pointSize
        }
    }
    
    override var textColor: UIColor! {
        didSet {
            textLayer.foregroundColor = textColor.cgColor
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            switch textAlignment {
            case .center:
                textLayer.alignmentMode = .center
            case .left:
                textLayer.alignmentMode = .left
            case .right:
                textLayer.alignmentMode = .right
            case .justified:
                textLayer.alignmentMode = .justified
            default:
                textLayer.alignmentMode = .natural
            }
        }
    }
    
    // This is needed to make the text layer properly size itself
    override func layoutSubviews() {
        super.layoutSubviews()
        textLayer.frame = bounds
    }
}

// MARK: - AnimatedTextView
class AnimatedTextView: UIView {
    
    // MARK: - Properties
    private var snapshots: [AnimatableLabel] = []
    private var originalText: String = ""
    private var textFont: UIFont
    private var textColor: UIColor
    private var randomColorIndices: [Int] = []
    
    // MARK: - Initialization
    init(text: String, font: UIFont, color: UIColor) {
        self.originalText = text
        self.textFont = font
        self.textColor = color
        super.init(frame: .zero)
        backgroundColor = .clear
        prepareAnimation()
    }
    
    required init?(coder: NSCoder) {
        self.textFont = UIFont.systemFont(ofSize: 48, weight: .black)
        self.textColor = .black
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLabelsLayout()
    }
    
    // MARK: - Public Methods
    
    /// Configure the animated text
    /// - Parameters:
    ///   - text: The text to animate
    ///   - font: Font to use for the text
    ///   - color: Text color
    func configure(text: String, font: UIFont, color: UIColor) {
        // Clear any existing animation
        cleanup()
        
        originalText = text
        textFont = font
        textColor = color
        
        prepareAnimation()
        updateLabelsLayout()
    }
    
    /// Enable random color flashes for some characters
    /// - Parameter percentage: Percentage of characters to animate (0-100)
    func enableRandomColorFlash(percentage: Int = 30) {
        guard !snapshots.isEmpty else { return }
        
        // Calculate how many characters to animate
        let count = max(1, Int(Double(snapshots.count) * Double(percentage) / 100.0))
        
        // Generate random indices to animate
        randomColorIndices = []
        while randomColorIndices.count < count {
            let randomIndex = Int.random(in: 0..<snapshots.count)
            if !randomColorIndices.contains(randomIndex) {
                randomColorIndices.append(randomIndex)
            }
        }
    }
    
    /// Start the text animation
    /// - Parameter completion: Optional callback when animation completes
    func animate(completion: (() -> Void)? = nil) {
        // Animate each character
        for (i, label) in snapshots.enumerated() {
            // Set initial state - already positioned at final Y position but with alpha 0
            let scale = 0.6
            label.alpha = 0
            label.textColor = .white
            label.transform = label.transform.scaledBy(x: scale, y: scale)
            
            // Use CAKeyframeAnimation for smoother Y position animation
            let positionAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
            
            // Define the position keyframes
            positionAnimation.values = [80.0, -20.0, 0.0]  // Start offset, overshoot, final position
            
            // Define the timing function for each segment
            positionAnimation.timingFunctions = [
                CAMediaTimingFunction(name: .easeOut),     // For the upward movement
                CAMediaTimingFunction(name: .easeInEaseOut) // For the settling movement
            ]
            
            // Define the duration of each segment (as a fraction of total duration)
            positionAnimation.keyTimes = [0.0, 0.3, 1.0]
            
            // Set the total duration and delay
            positionAnimation.duration = 0.8
            positionAnimation.beginTime = CACurrentMediaTime() + Double(i) * 0.05
            
            // Make sure the final state is preserved
            positionAnimation.fillMode = .forwards
            positionAnimation.isRemovedOnCompletion = false
            
            // Add the animation to the label's layer
            label.layer.add(positionAnimation, forKey: "positionAnimation")
            
            // Check if this character should have color animation
//            if let colorIndex = randomColorIndices.firstIndex(of: i), colorIndex < randomColors.count {
                
            if Int.random(in: 0...100) > 70 {
                print("true")
                // Create color keyframe animation
                let colorAnimation = CAKeyframeAnimation(keyPath: "foregroundColor")
                
                // Get the random color for this character
//                let randomColor = randomColors[colorIndex]
                let randomColor = CONFETTI_COLORS.randomElement()!

                // Define color keyframes
                colorAnimation.values = [
                    UIColor.white.cgColor,           // Start with white
                    randomColor.cgColor,             // Flash to random color at overshoot
                    UIColor.white.cgColor            // End with white
                ]
                
                // Define keyframe timing (match with position animation)
                colorAnimation.keyTimes = [0.0, 0.3, 0.75]
                
                // Define timing functions for smooth transitions
                colorAnimation.timingFunctions = [
                    CAMediaTimingFunction(name: .easeOut),
                    CAMediaTimingFunction(name: .easeInEaseOut)
                ]
                
                // Set duration and delay to match position animation
                colorAnimation.duration = 0.8
                colorAnimation.beginTime = CACurrentMediaTime() + Double(i) * 0.05
                
                // Make sure the final state is preserved
                colorAnimation.fillMode = .forwards
                colorAnimation.isRemovedOnCompletion = false
                
                // Apply the animation to the text layer
                (label.layer as! CATextLayer).add(colorAnimation, forKey: "colorAnimation")
            }
            
            // Fade in and scale with a simple animation
            UIView.animate(withDuration: 0.2, delay: Double(i) * 0.05, options: .curveLinear, animations: {
                label.alpha = 1.0
                label.transform = .identity
            }, completion: { _ in
                // Call completion handler after the last character finishes
                if i == self.snapshots.count - 1 {
                    // Wait for the animation to complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        // Reset the animation state but keep the labels visible
                        for label in self.snapshots {
                            label.layer.removeAllAnimations()
                            label.transform = .identity
                            label.textColor = .white // Ensure final color is white
                        }
                        completion?()
                    }
                }
            })
        }
    }
    
    // MARK: - Private Methods
    
    private func generateRandomBrightColor() -> UIColor {
        // Generate truly bright, saturated colors
        let hue = CGFloat.random(in: 0...1)
        let saturation: CGFloat = 1.0
        let brightness: CGFloat = 1.0
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
    
    private func prepareAnimation() {
        guard !originalText.isEmpty else { return }
        
        // Create an AnimatableLabel for each character
        for char in originalText {
            let charLabel = AnimatableLabel(frame: .zero)
            charLabel.text = String(char)
            charLabel.font = textFont
            charLabel.textColor = textColor
            charLabel.textAlignment = .center
            charLabel.alpha = 0
            
            // For smoother animation
            charLabel.layer.allowsEdgeAntialiasing = true
            
            addSubview(charLabel)
            snapshots.append(charLabel)
        }
    }
    
    private func updateLabelsLayout() {
        guard !snapshots.isEmpty else { return }
        
        // Calculate total width needed for all characters
        var totalWidth: CGFloat = 0
        let heights: [CGFloat] = snapshots.map { label in
            let size = label.text?.size(withAttributes: [.font: textFont]) ?? .zero
            totalWidth += size.width
            return size.height
        }
        
        let maxHeight = heights.max() ?? 0
        
        // Position each label
        var currentX: CGFloat = (bounds.width - totalWidth) / 2
        
        for label in snapshots {
            let charSize = label.text?.size(withAttributes: [.font: textFont]) ?? .zero
            label.frame = CGRect(
                x: currentX,
                y: (bounds.height - maxHeight) / 2,
                width: charSize.width,
                height: maxHeight
            )
            currentX += charSize.width
        }
        
        // Set the intrinsic content size
        invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        guard !snapshots.isEmpty else { return CGSize(width: 100, height: 50) }
        
        // Calculate total width and max height
        var totalWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for label in snapshots {
            let size = label.text?.size(withAttributes: [.font: textFont]) ?? .zero
            totalWidth += size.width
            maxHeight = max(maxHeight, size.height)
        }
        
        return CGSize(width: totalWidth, height: maxHeight)
    }
    
    private func cleanup() {
        // Remove all existing character labels
        for view in snapshots {
            view.removeFromSuperview()
        }
        snapshots.removeAll()
        randomColorIndices.removeAll()
    }
}
