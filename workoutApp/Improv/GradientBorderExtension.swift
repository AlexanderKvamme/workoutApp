//
//  GradientBorderExtension.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 06/05/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit

extension UIView {
    // Stored properties using associated objects
    private struct AssociatedKeys {
        static var gradientLayer = "gradientBorderLayer"
        static var shapeLayer = "gradientBorderShapeLayer"
    }
    
    private var gradientLayer: CAGradientLayer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gradientLayer) as? CAGradientLayer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gradientLayer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var shapeLayer: CAShapeLayer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.shapeLayer) as? CAShapeLayer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.shapeLayer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // Add gradient border
    func addGradientBorder(width: CGFloat, colors: [UIColor], cornerRadius: CGFloat? = nil) {
        // Remove existing gradient if any
        removeGradientBorder()
        
        // Create shape layer for border
        let shape = CAShapeLayer()
        shape.lineWidth = width
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.white.cgColor
        
        // Create gradient layer
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        // Set the border path
        let radius = cornerRadius ?? layer.cornerRadius
        let inset = width / 2
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: inset, dy: inset), cornerRadius: radius)
        shape.path = path.cgPath
        
        // Apply mask
        gradient.mask = shape
        
        // Add to layer
        layer.addSublayer(gradient)
        
        // Store references
        self.gradientLayer = gradient
        self.shapeLayer = shape
        
        // Make sure layout updates when view changes
        layer.setNeedsLayout()
    }
    
    // Remove gradient border
    func removeGradientBorder() {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
        shapeLayer = nil
    }
    
    // Animate the gradient
    func animateGradientBorder(duration: TimeInterval = 2.0) {
        guard let gradient = gradientLayer else { return }
        
        // Set up colors for animation
        let colors = gradient.colors ?? []
        guard colors.count >= 2 else { return }
        
        let firstColor = colors.first!
        let lastColor = colors.last!
        
        // Three colors for smooth animation
        gradient.colors = [firstColor, lastColor, firstColor]
        gradient.locations = [0.0, 0.5, 1.0]
        
        // Create animation
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.5, 1.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        
        // Add animation
        gradient.add(animation, forKey: "flowAnimation")
    }
    
    // Stop animation
    func stopGradientBorderAnimation() {
        gradientLayer?.removeAllAnimations()
    }
    
    // Update gradient border on layout changes
    func updateGradientBorderLayout() {
        guard let gradient = gradientLayer, let shape = shapeLayer else { return }
        
        // Update frames and paths
        gradient.frame = bounds
        let inset = shape.lineWidth / 2
        let radius = layer.cornerRadius
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: inset, dy: inset), cornerRadius: radius)
        shape.path = path.cgPath
    }
}
