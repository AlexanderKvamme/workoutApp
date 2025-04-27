//
//  Dots.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 27/04/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit

class DotsView: UIView {
    
    // MARK: - Properties
    
    private var dotsLayers: [CAShapeLayer] = []
    private var currentDotCount: Int = 0
    private var dotSize: CGFloat = 8.0
    private var dotSpacing: CGFloat = 5.0
    private var dotColor: UIColor = .white
    private var dotAnimationDuration: TimeInterval = 0.3
    private var maxDots: Int = 8
    
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
        isUserInteractionEnabled = false
        clipsToBounds = false
    }
    
    // MARK: - Public Methods
    
    /// Configure the dots appearance
    /// - Parameters:
    ///   - count: Current number of dots to display (0-8)
    ///   - size: Size of each dot
    ///   - spacing: Spacing between dots
    ///   - color: Color of the dots
    ///   - maxCount: Maximum number of dots (default is 8)
    func configureDots(count: Int = 0,
                       size: CGFloat = 8.0,
                       spacing: CGFloat = 5.0,
                       color: UIColor = .white,
                       maxCount: Int = 8) {
        
        self.currentDotCount = max(0, min(count, maxCount))
        self.dotSize = size
        self.dotSpacing = spacing
        self.dotColor = color
        self.maxDots = maxCount
        
        updateDots(animated: false)
    }
    
    /// Increment dot count and animate new dots
    /// - Parameters:
    ///   - color: Optional override for dot color
    ///   - animated: Whether to animate the dots appearing
    ///   - completion: Optional completion handler
    func bumpDots(color: UIColor? = nil,
                  animated: Bool = true,
                  completion: (() -> Void)? = nil) {
        
        // Increment dot count
        currentDotCount = min(currentDotCount + 1, maxDots)
        
        // Use provided color or default
        if let color = color {
            self.dotColor = color
        }
        
        // Update dots
        updateDots(animated: animated)
        
        // Add haptic feedback
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
        
        // Call completion handler if provided
        if animated {
            DispatchQueue.main.asyncAfter(deadline: .now() + dotAnimationDuration) {
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    /// Reset dot count to zero and remove all dots
    /// - Parameter animated: Whether to animate the dots disappearing
    func resetDots(animated: Bool = true) {
        if animated {
            // Animate dots fading out
            CATransaction.begin()
            CATransaction.setAnimationDuration(dotAnimationDuration)
            CATransaction.setCompletionBlock { [weak self] in
                self?.dotsLayers.forEach { $0.removeFromSuperlayer() }
                self?.dotsLayers.removeAll()
                self?.currentDotCount = 0
            }
            
            for dotLayer in dotsLayers {
                dotLayer.opacity = 0
                dotLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
            }
            
            CATransaction.commit()
        } else {
            // Remove dots immediately
            dotsLayers.forEach { $0.removeFromSuperlayer() }
            dotsLayers.removeAll()
            currentDotCount = 0
        }
    }
    
    /// Get the current dot count
    func getDotCount() -> Int {
        return currentDotCount
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateDots(animated: false)
    }
    
    // MARK: - Private Methods
    
    private func updateDots(animated: Bool) {
        // Clear any existing dots
        dotsLayers.forEach { $0.removeFromSuperlayer() }
        dotsLayers.removeAll()
        
        // If no dots to display, return early
        if currentDotCount == 0 {
            return
        }
        
        // Calculate top and bottom dot counts
        let topCount = min(currentDotCount, 4)
        let bottomCount = max(0, currentDotCount - 4)
        
        // Draw top dots
        if topCount > 0 {
            drawDotsOnEdge(count: topCount,
                          edgeIndex: 5, // Left edge becomes top after rotation
                          color: dotColor,
                          animated: animated)
        }
        
        // Draw bottom dots
        if bottomCount > 0 {
            drawDotsOnEdge(count: bottomCount,
                          edgeIndex: 2, // Right edge becomes bottom after rotation
                          color: dotColor,
                          animated: animated)
        }
    }
    
    /// Helper method to draw dots on a specific edge of the hexagon
    private func drawDotsOnEdge(count: Int, edgeIndex: Int, color: UIColor, animated: Bool) {
        let size = bounds.width
        let center = CGPoint(x: size/2, y: size/2)
        let radius = size/2 - 4 // Slightly smaller than the hexagon radius
        
        // Calculate the angle for the specified edge, rotated by π/2
        let edgeAngle = CGFloat(edgeIndex) * (CGFloat.pi / 3) + CGFloat.pi/2
        
        // Calculate the center point of the edge
        let edgeCenter = CGPoint(
            x: center.x + radius * cos(edgeAngle),
            y: center.y + radius * sin(edgeAngle)
        )
        
        // Calculate perpendicular direction along the edge
        let perpAngle = edgeAngle + CGFloat.pi/2
        let perpX = cos(perpAngle)
        let perpY = sin(perpAngle)
        
        // Calculate total width of dots
        let totalWidth = CGFloat(count) * dotSize + CGFloat(count - 1) * dotSpacing
        
        // Calculate starting position
        let startX = edgeCenter.x - (totalWidth / 2) * perpX
        let startY = edgeCenter.y - (totalWidth / 2) * perpY
        
        // Calculate inset direction (toward center)
        let insetFactor: CGFloat = 0.3
        let insetX = (center.x - edgeCenter.x) * insetFactor
        let insetY = (center.y - edgeCenter.y) * insetFactor
        
        // Create and position each dot
        for i in 0..<count {
            let dotLayer = CAShapeLayer()
            let dotPath = UIBezierPath(ovalIn: CGRect(x: -dotSize/2, y: -dotSize/2, width: dotSize, height: dotSize))
            
            dotLayer.path = dotPath.cgPath
            dotLayer.fillColor = color.cgColor
            
            // Position the dot along the edge with inset
            let position = CGPoint(
                x: startX + CGFloat(i) * (dotSize + dotSpacing) * perpX + insetX,
                y: startY + CGFloat(i) * (dotSize + dotSpacing) * perpY + insetY
            )
            dotLayer.position = position
            
            // Initial state for animation
            if animated {
                dotLayer.opacity = 0
                dotLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
            }
            
            // Add to view
            layer.addSublayer(dotLayer)
            dotsLayers.append(dotLayer)
            
            // Animate appearance
            if animated {
                let fadeIn = CABasicAnimation(keyPath: "opacity")
                fadeIn.fromValue = 0
                fadeIn.toValue = 1
                fadeIn.duration = dotAnimationDuration
                
                let scaleUp = CABasicAnimation(keyPath: "transform")
                scaleUp.fromValue = CATransform3DMakeScale(0.5, 0.5, 1)
                scaleUp.toValue = CATransform3DIdentity
                scaleUp.duration = dotAnimationDuration
                
                // Add delay based on dot index for sequential animation
                let delay = TimeInterval(i) * 0.05
                fadeIn.beginTime = CACurrentMediaTime() + delay
                scaleUp.beginTime = CACurrentMediaTime() + delay
                
                dotLayer.opacity = 1
                dotLayer.transform = CATransform3DIdentity
                
                dotLayer.add(fadeIn, forKey: "fadeIn")
                dotLayer.add(scaleUp, forKey: "scaleUp")
            }
        }
    }
}
