
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

// MARK: - AnimatedTextView
class AnimatedTextView: UIView {
    
    // MARK: - Properties
    private var snapshots: [UILabel] = []
    private var originalText: String = ""
    private var textFont: UIFont
    private var textColor: UIColor
    
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
    
    /// Start the text animation
    /// - Parameter completion: Optional callback when animation completes
    func animate(completion: (() -> Void)? = nil) {
        // Animate each character
        for (i, label) in snapshots.enumerated() {
            // Set initial state - already positioned at final Y position but with alpha 0
            label.alpha = 0
            
            // Use CAKeyframeAnimation for smoother Y position animation
            let positionAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
            
            // Define the position keyframes
            positionAnimation.values = [40.0, -15.0, 0.0]  // Start offset, overshoot, final position
            
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
            
            // Fade in with a simple animation
            UIView.animate(withDuration: 0.2, delay: Double(i) * 0.05, options: .curveLinear, animations: {
                label.alpha = 1.0
            }, completion: { _ in
                // Call completion handler after the last character finishes
                if i == self.snapshots.count - 1 {
                    // Wait for the animation to complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        // Reset the animation state but keep the labels visible
                        for label in self.snapshots {
                            label.layer.removeAllAnimations()
                            label.transform = .identity
                        }
                        completion?()
                    }
                }
            })
        }
    }
    
    // MARK: - Private Methods
    
    private func prepareAnimation() {
        guard !originalText.isEmpty else { return }
        
        // Create a label for each character
        for char in originalText {
            let charLabel = UILabel()
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
        
        for (i, label) in snapshots.enumerated() {
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
    }
}


