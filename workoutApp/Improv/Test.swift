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
    
    // Extra padding to prevent clipping
    private let horizontalPadding: CGFloat = 0
    private let verticalPadding: CGFloat = 0
    
    // MARK: - Initialization
    init(text: String, font: UIFont, color: UIColor) {
        self.originalText = text
        self.textFont = font
        self.textColor = color
        super.init(frame: .zero)
        backgroundColor = .random
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
    func configure(text: String, font: UIFont, color: UIColor) {
        // Clear any existing animation
        cleanup()
        
        originalText = text
        textFont = font
        textColor = color
        
        prepareAnimation()
        updateLabelsLayout()
    }
    
    func enableRandomColorFlash(percentage: Int = 30) {
        guard !charLabels.isEmpty else { return }
        
        // Calculate how many characters to animate
        let count = max(1, Int(Double(charLabels.count) * Double(percentage) / 100.0))
        
        // Generate random indices to animate
        randomColorIndices = []
        while randomColorIndices.count < count {
            let randomIndex = Int.random(in: 0..<charLabels.count)
            if !randomColorIndices.contains(randomIndex) {
                randomColorIndices.append(randomIndex)
            }
        }
    }
    
    func animate(completion: (() -> Void)? = nil) {
        // Animate each character
        for (i, label) in charLabels.enumerated() {
            // Set initial state
            let scale = 1.0
            label.alpha = 0
            label.textColor = .white
            label.transform = label.transform.scaledBy(x: scale, y: scale)
            label.backgroundColor = .random
            
            // Use CAKeyframeAnimation for smoother Y position animation
            let positionAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
            
            // Define the position keyframes
            positionAnimation.values = [80.0, -20.0, 0.0]  // Start offset, overshoot, final position
            
            // Define the timing function for each segment
            positionAnimation.timingFunctions = [
                CAMediaTimingFunction(name: .easeOut),
                CAMediaTimingFunction(name: .easeInEaseOut)
            ]
            
            // Define the duration of each segment
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
            if Int.random(in: 0...100) > 70 {
                // Create color keyframe animation
                let colorAnimation = CAKeyframeAnimation(keyPath: "foregroundColor")
                
                // Get the random color
                let randomColor = CONFETTI_COLORS.randomElement()!
                
                // Define color keyframes
                colorAnimation.values = [
                    UIColor.white.cgColor,
                    randomColor.cgColor,
                    UIColor.white.cgColor
                ]
                
                // Define keyframe timing
                colorAnimation.keyTimes = [0.0, 0.3, 0.75]
                
                // Define timing functions
                colorAnimation.timingFunctions = [
                    CAMediaTimingFunction(name: .easeOut),
                    CAMediaTimingFunction(name: .easeInEaseOut)
                ]
                
                // Set duration and delay
                colorAnimation.duration = 0.8
                colorAnimation.beginTime = CACurrentMediaTime() + Double(i) * 0.05
                
                // Make sure the final state is preserved
                colorAnimation.fillMode = .forwards
                colorAnimation.isRemovedOnCompletion = false
                
                // Apply the animation to the label's layer
                label.layer.add(colorAnimation, forKey: "colorAnimation")
            }
            
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
                            label.textColor = .white
                        }
                        completion?()
                    }
                }
            })
            
            // Animate font weight if using variable font
             let vfont = VFonts.elza(size: textFont.pointSize)
                animateFontWeight(for: label, with: vfont, duration: 0.8, delay: Double(i) * 0.05)
        }
    }
    
    // MARK: - Private Methods
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
            
            // Debug visualization
            // label.backgroundColor = UIColor(red: CGFloat.random(in: 0...0.5), green: CGFloat.random(in: 0...0.5), blue: CGFloat.random(in: 0...0.5), alpha: 0.3)
            // label.layer.borderWidth = 1
            // label.layer.borderColor = UIColor.red.cgColor
            
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
        
        // Position each label
        var currentX: CGFloat = (bounds.width - totalWidth) / 2
        
        for label in charLabels {
            label.frame = CGRect(
                x: currentX,
                y: (bounds.height - maxHeight) / 2,
                width: label.frame.width,
                height: maxHeight
            )
            currentX += label.frame.width
        }
        
        // Set the intrinsic content size
        invalidateIntrinsicContentSize()
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
    
    private func animateFontWeight(for label: UILabel, with vfont: VFont, duration: TimeInterval, delay: TimeInterval = 0) {
        let steps: CGFloat = 10
        let stepDuration = duration / Double(steps)
        
        for i in 0...Int(steps) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + stepDuration * Double(i)) {
                // Calculate the weight for the variable font
                let weight = CGFloat(i) / steps // Normalize to [0, 1]
                
                // Create font with the specified weight
                let newFont = vfont.make(weight: weight)
                
                // Update the label's font
                label.font = newFont
            }
        }
    }
    
    private func cleanup() {
        // Remove all existing character labels
        for view in charLabels {
            view.removeFromSuperview()
        }
        charLabels.removeAll()
        randomColorIndices.removeAll()
    }
}
