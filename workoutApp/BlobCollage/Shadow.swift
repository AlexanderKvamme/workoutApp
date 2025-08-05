import UIKit
import CoreGraphics

// MARK: - Hard Streaking Shadow Extension
extension UIView {
    func addLongShadow(offset: CGSize, cornerRadius: CGFloat, steps: Int = 30) {
        // Remove existing shadow layer
        layer.sublayers?.removeAll { $0.name == "long_shadow" }
        
        let shadowLayer = CALayer()
        shadowLayer.name = "long_shadow"
        shadowLayer.frame = CGRect(
            x: min(0, offset.width),
            y: min(0, offset.height),
            width: bounds.width + abs(offset.width),
            height: bounds.height + abs(offset.height)
        )
        
        // Create the hard shadow image
        let renderer = UIGraphicsImageRenderer(size: shadowLayer.bounds.size)
        let shadowImage = renderer.image { context in
            let cgContext = context.cgContext
            
            // Set shadow color - solid black, no fading
            cgContext.setFillColor(UIColor.black.cgColor)
            cgContext.setAlpha(1.0) // Hard shadow - no gradient
            
            // Calculate step size
            let stepX = offset.width / CGFloat(steps)
            let stepY = offset.height / CGFloat(steps)
            
            // Draw multiple copies of the shape along the shadow path
            for i in 0..<steps {
                let shadowX = CGFloat(i) * stepX + (offset.width < 0 ? abs(offset.width) : 0)
                let shadowY = CGFloat(i) * stepY + (offset.height < 0 ? abs(offset.height) : 0)
                
                let shadowRect = CGRect(
                    x: shadowX,
                    y: shadowY,
                    width: bounds.width,
                    height: bounds.height
                )
                
                // Draw the shadow shape
                let shadowPath = UIBezierPath(roundedRect: shadowRect, cornerRadius: cornerRadius)
                cgContext.addPath(shadowPath.cgPath)
                cgContext.fillPath()
            }
        }
        
        // Create shadow layer with the generated image
        shadowLayer.contents = shadowImage.cgImage
        layer.insertSublayer(shadowLayer, at: 0)
    }
}
