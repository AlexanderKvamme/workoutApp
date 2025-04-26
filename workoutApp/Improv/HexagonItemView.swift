//
//  HexagonItemView.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 26/04/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//
import AKKIT
import UIKit


// MARK: - HexagonItemView
class HexagonItemView: UIView {
    private var hexagonLayer: CAShapeLayer?
    private var textLabel: UILabel?
    
    // Long press properties
    private let longPressDuration: TimeInterval = 1.0
    private var progressShapeLayer: CAShapeLayer?
    private var animationStartTime: CFTimeInterval?
    private var displayLink: CADisplayLink?
    private var completionHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        // Create hexagon shape
        let hexagonLayer = CAShapeLayer()
        hexagonLayer.path = createHexagonPath().cgPath
        hexagonLayer.fillColor = UIColor.black.cgColor
        layer.addSublayer(hexagonLayer)
        self.hexagonLayer = hexagonLayer
        
        // Add text label
        let textLabel = UILabel()
        textLabel.frame = bounds.insetBy(dx: bounds.width * 0.15, dy: bounds.height * 0.15)
        textLabel.textColor = .white
        textLabel.textAlignment = .center
        textLabel.font = AKFont.round(.bold, 16)
        textLabel.numberOfLines = 0
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.5
        addSubview(textLabel)
        self.textLabel = textLabel
    }
    
    func configure(withText text: String) {
        textLabel?.text = text
    }
    
    func animateHighlight() {
        guard let hexagonLayer = hexagonLayer else { return }
        
        let originalColor = hexagonLayer.fillColor
        let highlightColor = UIColor.systemBlue.cgColor
        
        let animation = CABasicAnimation(keyPath: "fillColor")
        animation.fromValue = originalColor
        animation.toValue = highlightColor
        animation.duration = 0.1
        animation.autoreverses = true
        animation.repeatCount = 1
        hexagonLayer.add(animation, forKey: "highlightAnimation")
    }
    
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
    
    // MARK: - Long Press Handling
    
    /// Set the action to be performed when long press completes
    func setLongPressAction(_ completion: @escaping () -> Void) {
        completionHandler = completion
    }
    
    func startLongPressAnimation() {
        // Cancel any existing animation
        cancelLongPressAnimation()
        
        // Create progress shape layer if needed
        if progressShapeLayer == nil {
            let progressLayer = CAShapeLayer()
            progressLayer.path = createHexagonPath().cgPath
            progressLayer.fillColor = UIColor.systemBlue.withAlphaComponent(0.5).cgColor // Semi-transparent fill
            progressLayer.opacity = 0 // Start with opacity 0
            layer.insertSublayer(progressLayer, below: hexagonLayer) // Insert below the main hexagon
            progressShapeLayer = progressLayer
        }
        
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
}
