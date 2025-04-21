import UIKit

class HoneycombViewController: UIViewController {
    
    // Configuration
    private let numberOfHexagons = 7
    private let hexagonSize: CGFloat = 75 // Slightly smaller hexagons
    private let spacing: CGFloat = 2 // Small gap between hexagons
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        createHoneycombGrid()
    }
    
    private func createHoneycombGrid() {
        // Basic measurements
        let width = hexagonSize
        let height = width * 0.866 // height of a hexagon (sqrt(3)/2 * width)
        
        // For a perfect tessellation with a small gap
        let horizontalSpacing = width + spacing
        let verticalSpacing = height + spacing
        
        // Define positions to match the exact pattern in the image
        // Format: (q, r, isBlack) - using axial coordinates
        let positions = [
            (0, 0, false),    // Index 0: Center (white)
            (1, -1, true),    // Index 1: Top right (black)
            (0, -1, false),   // Index 2: Top (white)
            (-1, 0, true),    // Index 3: Left (black)
            (1, 0, true),     // Index 4: Right (black)
            (-1, 1, false),   // Index 5: Bottom left (white)
            (0, 1, true)      // Index 6: Bottom (black)
        ]
        
        // Center the entire pattern in the view
        let centerX = view.bounds.width / 2
        let centerY = view.bounds.height / 2
        
        // Position and add each hexagon
        for (index, position) in positions.enumerated() {
            // Convert axial coordinates to pixel coordinates with spacing
            // This formula ensures tessellation with small gaps
            let xPos = centerX + (CGFloat(position.0) * horizontalSpacing * 0.75)
            let yPos = centerY + (CGFloat(position.0) * verticalSpacing * 0.5 + CGFloat(position.1) * verticalSpacing)
            
            let hexButton = createHexagon(
                x: xPos - width/2,
                y: yPos - height/2,
                isBlack: position.2,
                index: index
            )
            
            view.addSubview(hexButton)
        }
    }
    
    private func createHexagon(x: CGFloat, y: CGFloat, isBlack: Bool, index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: x, y: y, width: hexagonSize, height: hexagonSize)
        
        // Create hexagon shape
        let hexagonLayer = CAShapeLayer()
        hexagonLayer.path = createHexagonPath(size: hexagonSize).cgPath
        
        // Set color based on the pattern
        hexagonLayer.fillColor = isBlack ? UIColor.black.cgColor : UIColor.white.cgColor
        
        // Add border
        let borderLayer = CAShapeLayer()
        borderLayer.path = hexagonLayer.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = isBlack ? UIColor.white.cgColor : UIColor.black.cgColor
        borderLayer.lineWidth = 2
        
        button.layer.addSublayer(hexagonLayer)
        button.layer.addSublayer(borderLayer)
        
        // Add index label
        let label = UILabel(frame: button.bounds)
        label.text = "\(index)"
        label.textColor = isBlack ? .white : .black
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        button.addSubview(label)
        
        // Add tap action
        button.addTarget(self, action: #selector(hexagonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    private func createHexagonPath(size: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let center = CGPoint(x: size/2, y: size/2)
        let radius = size/2 - 2 // Smaller radius to prevent overlap
        let cornerRadius: CGFloat = 10
        
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
            
            if i == 0 {
                path.move(to: currentPoint)
            }
            
            // Simple approach for rounded corners
            let distance = sqrt(pow(nextPoint.x - currentPoint.x, 2) + pow(nextPoint.y - currentPoint.y, 2))
            let directionX = (nextPoint.x - currentPoint.x) / distance
            let directionY = (nextPoint.y - currentPoint.y) / distance
            
            let controlPoint = CGPoint(
                x: (currentPoint.x + nextPoint.x) / 2 + directionY * cornerRadius * 0.5,
                y: (currentPoint.y + nextPoint.y) / 2 - directionX * cornerRadius * 0.5
            )
            
            path.addLine(to: currentPoint)
            path.addQuadCurve(to: nextPoint, controlPoint: controlPoint)
        }
        
        path.close()
        return path
    }
    
    @objc private func hexagonTapped(_ sender: UIButton) {
        // Toggle appearance when tapped
        if let hexLayer = sender.layer.sublayers?.first as? CAShapeLayer,
           let borderLayer = sender.layer.sublayers?[1] as? CAShapeLayer {
            
            let isBlack = hexLayer.fillColor == UIColor.black.cgColor
            
            // Update fill color with animation
            let fillAnimation = CABasicAnimation(keyPath: "fillColor")
            fillAnimation.fromValue = hexLayer.fillColor
            fillAnimation.toValue = isBlack ? UIColor.white.cgColor : UIColor.black.cgColor
            fillAnimation.duration = 0.2
            hexLayer.add(fillAnimation, forKey: "fillColor")
            hexLayer.fillColor = isBlack ? UIColor.white.cgColor : UIColor.black.cgColor
            
            // Update border color with animation
            let strokeAnimation = CABasicAnimation(keyPath: "strokeColor")
            strokeAnimation.fromValue = borderLayer.strokeColor
            strokeAnimation.toValue = isBlack ? UIColor.black.cgColor : UIColor.white.cgColor
            strokeAnimation.duration = 0.2
            borderLayer.add(strokeAnimation, forKey: "strokeColor")
            borderLayer.strokeColor = isBlack ? UIColor.black.cgColor : UIColor.white.cgColor
            
            // Update text color
            for subview in sender.subviews {
                if let label = subview as? UILabel {
                    label.textColor = isBlack ? .black : .white
                }
            }
        }
    }
}
