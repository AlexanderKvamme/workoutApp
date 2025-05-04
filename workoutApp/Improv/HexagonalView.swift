//
//  HexagonalView.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 04/05/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit

// MARK: - HexagonalView
class HexagonalView: UIView {
    
    // MARK: - Properties
    private var cornerRadius: CGFloat
    private var rotationOffset: CGFloat
    
    // Shape layers
    private var fillLayer: CAShapeLayer?
    private var strokeLayer: CAShapeLayer?
    
    // MARK: - Customization Properties
    var fillColor: UIColor = .white {
        didSet {
            fillLayer?.fillColor = fillColor.cgColor
            setNeedsLayout()
        }
    }
    
    var strokeColor: UIColor? {
        didSet {
            strokeLayer?.strokeColor = strokeColor?.cgColor
            setNeedsLayout()
        }
    }
    
    var strokeWidth: CGFloat = 0 {
        didSet {
            strokeLayer?.lineWidth = strokeWidth
            setNeedsLayout()
        }
    }
    
    // MARK: - Initialization
    init(frame: CGRect, cornerRadius: CGFloat = 15.0, rotationOffset: CGFloat = 0) {
        self.cornerRadius = cornerRadius
        self.rotationOffset = rotationOffset
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        self.cornerRadius = 15.0
        self.rotationOffset = 0
        super.init(coder: coder)
        setupLayers()
    }
    
    // MARK: - Setup
    private func setupLayers() {
        backgroundColor = .clear
        
        // Create fill layer
        let fill = CAShapeLayer()
        fill.fillColor = fillColor.cgColor
        layer.addSublayer(fill)
        fillLayer = fill
        
        // Create stroke layer if needed
        if let strokeColor = strokeColor, strokeWidth > 0 {
            let stroke = CAShapeLayer()
            stroke.fillColor = UIColor.clear.cgColor
            stroke.strokeColor = strokeColor.cgColor
            stroke.lineWidth = strokeWidth
            layer.addSublayer(stroke)
            strokeLayer = stroke
        }
        
        // Initial layout
        updateHexagonPath()
    }
    
    // MARK: - Path Creation
    
    /// Creates a hexagon path that fills the view bounds
    func createHexagonPath() -> UIBezierPath {
        return roundedPolygonPath(
            rect: bounds,
            lineWidth: strokeWidth,
            sides: 6,  // Hexagon
            cornerRadius: cornerRadius,
            rotationOffset: rotationOffset
        )
    }
    
    /// Creates a rounded polygon path with the specified parameters
    func roundedPolygonPath(rect: CGRect, lineWidth: CGFloat, sides: Int, cornerRadius: CGFloat, rotationOffset: CGFloat = 0) -> UIBezierPath {
        let path = UIBezierPath()
        let theta: CGFloat = CGFloat(2.0 * Double.pi) / CGFloat(sides) // How much to turn at every corner
        let width = min(rect.size.width, rect.size.height)        // Width of the square
        
        let center = CGPoint(x: rect.origin.x + rect.size.width / 2.0, y: rect.origin.y + rect.size.height / 2.0)
        
        // Radius of the circle that encircles the polygon
        // Notice that the radius is adjusted for the corners, that way the largest outer
        // dimension of the resulting shape is always exactly the width - linewidth
        let radius = (width - lineWidth + cornerRadius - (cos(theta) * cornerRadius)) / 2.0
        
        // Start drawing at a point, which by default is at the right hand edge
        // but can be offset
        var angle = CGFloat(rotationOffset)
        
        let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
        path.move(to: CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta)))
        
        for _ in 0..<sides {
            angle += theta
            
            let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
            let tip = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            let start = CGPoint(x: corner.x + cornerRadius * cos(angle - theta), y: corner.y + cornerRadius * sin(angle - theta))
            let end = CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta))
            
            path.addLine(to: start)
            path.addQuadCurve(to: end, controlPoint: tip)
        }
        
        path.close()
        return path
    }
    
    /// Updates the hexagon path for both fill and stroke layers
    private func updateHexagonPath() {
        let hexPath = createHexagonPath()
        
        // Update fill layer
        fillLayer?.path = hexPath.cgPath
        
        // Update stroke layer if it exists
        strokeLayer?.path = hexPath.cgPath
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateHexagonPath()
    }
    
    // MARK: - Hit Testing
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hexPath = createHexagonPath()
        return hexPath.contains(point)
    }
    
    // MARK: - Public Methods
    
    /// Updates the corner radius of the hexagon
    func updateCornerRadius(_ radius: CGFloat) {
        self.cornerRadius = radius
        setNeedsLayout()
    }
    
    /// Updates the rotation offset of the hexagon
    func updateRotationOffset(_ offset: CGFloat) {
        self.rotationOffset = offset
        setNeedsLayout()
    }
    
    /// Animates a color change for the hexagon
    func animateColorChange(to newColor: UIColor, duration: TimeInterval = 0.3) {
        let colorAnimation = CABasicAnimation(keyPath: "fillColor")
        colorAnimation.fromValue = fillLayer?.fillColor
        colorAnimation.toValue = newColor.cgColor
        colorAnimation.duration = duration
        
        fillLayer?.add(colorAnimation, forKey: "fillColorAnimation")
        fillColor = newColor
    }
    
    func animateColorChangeInUIViewBlock(to newColor: UIColor, duration: TimeInterval) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        fillLayer?.fillColor = newColor.cgColor
        fillColor = newColor
        CATransaction.commit()
    }
    
    /// Updates the stroke appearance
    func updateStroke(color: UIColor?, width: CGFloat = 1.0) {
        strokeColor = color
        strokeWidth = width
        
        if let color = color, width > 0 {
            if strokeLayer == nil {
                let stroke = CAShapeLayer()
                stroke.fillColor = UIColor.clear.cgColor
                stroke.strokeColor = color.cgColor
                stroke.lineWidth = width
                layer.addSublayer(stroke)
                strokeLayer = stroke
                updateHexagonPath()
            } else {
                strokeLayer?.strokeColor = color.cgColor
                strokeLayer?.lineWidth = width
            }
        } else {
            // Remove stroke layer if not needed
            strokeLayer?.removeFromSuperlayer()
            strokeLayer = nil
        }
    }
}
