import UIKit

class HoneycombViewController: UIViewController {
    
    // Configuration
    private let numberOfHexagons = 7
    private let hexagonSize: CGFloat = UIScreen.main.bounds.width/3
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
            (0, 0, false),    // Index 0: Center
            (1, -1, true),    // Index 1: Top right
            (0, -1, false),   // Index 2: Top
            (-1, 0, true),    // Index 3: Left
            (1, 0, true),     // Index 4: Right
            (-1, 1, false),   // Index 5: Bottom left
            (0, 1, true)      // Index 6: Bottom
        ]
        
        // Sample texts for each hexagon
        let texts = [
            "Mountain\nPose",
            "Forward\nFold",
            "Downward\nDog",
            "Warrior\nI",
            "Warrior\nII",
            "Triangle\nPose",
            "Tree\nPose"
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
                index: index,
                text: texts[index]
            )
            
            view.addSubview(hexButton)
        }
    }
    
    private func createHexagon(x: CGFloat, y: CGFloat, index: Int, text: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: x, y: y, width: hexagonSize, height: hexagonSize)
        
        // Create hexagon shape
        let hexagonLayer = CAShapeLayer()
        hexagonLayer.path = createHexagonPath(size: hexagonSize).cgPath
        
        // Set all hexagons to black
        hexagonLayer.fillColor = UIColor.black.cgColor
        
        // Add border
        let borderLayer = CAShapeLayer()
        borderLayer.path = hexagonLayer.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.lineWidth = 2
        
        button.layer.addSublayer(hexagonLayer)
        button.layer.addSublayer(borderLayer)
        
        // Create a mask for the textView to fit within the hexagon
        let maskLayer = CAShapeLayer()
        maskLayer.path = createHexagonPath(size: hexagonSize * 0.8).cgPath // Slightly smaller for padding
        
        // Replace the UITextView with a UILabel
        let textView = UILabel()
        textView.frame = CGRect(
            x: hexagonSize * 0.1,
            y: hexagonSize * 0.1,
            width: hexagonSize * 0.8,
            height: hexagonSize * 0.8
        )
        textView.text = text
        textView.textColor = .white
        textView.textAlignment = .center
        textView.font = UIFont.boldSystemFont(ofSize: 18)
        textView.backgroundColor = .clear
        textView.numberOfLines = 0 // Allow multiple lines
        textView.layer.mask = maskLayer

        // Center vertically
        textView.adjustsFontSizeToFitWidth = false
        textView.lineBreakMode = .byWordWrapping
        textView.baselineAdjustment = .alignCenters

        button.addSubview(textView)
        
        // Center the text vertically
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let yOffset = (textView.frame.size.height - newSize.height) / 2
        let topOffset = max(0, yOffset)
        
        button.addSubview(textView)
        
        // Add tap action
        button.addTarget(self, action: #selector(hexagonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    private func createHexagonPath(size: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let center = CGPoint(x: size/2, y: size/2)
        let radius = size/2 - 2 // Smaller radius to prevent overlap
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
        
        // Create a hexagon with ONLY rounded corners (straight sides)
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
                if let textView = subview as? UITextView {
                    textView.textColor = isBlack ? .black : .white
                }
            }
        }
    }
}
