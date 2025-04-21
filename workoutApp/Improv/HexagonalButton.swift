
import UIKit

class HexagonalButton: UIButton {
    
    private let numberLabel = UILabel()
    private let tLabel = UILabel()
    private let subLabel = UILabel()
    private let dotView = UIView()
    private let cornerRadius: CGFloat = 15.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        // Create hexagonal shape with rounded corners
        let hexagonPath = createHexagonPath()
        
        // Create shape layer with hexagon path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = hexagonPath.cgPath
        
        // Create gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.5, green: 0.7, blue: 0.95, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        // Apply mask to gradient
        gradientLayer.mask = shapeLayer
        layer.addSublayer(gradientLayer)
        
        // Add dot view
        dotView.backgroundColor = .black
        dotView.layer.cornerRadius = 3
        addSubview(dotView)
        
        // Configure number label
        numberLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        numberLabel.textColor = .black
        numberLabel.text = "3"
        addSubview(numberLabel)
        
        // Configure title label
        tLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tLabel.textColor = .black
        tLabel.text = "walk 15 min"
        addSubview(tLabel)
        
        // Configure subtitle label
        subLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subLabel.textColor = .darkGray
        subLabel.text = "daily"
        addSubview(subLabel)
        
        // Set positions
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update gradient frame
        if let gradientLayer = layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = bounds
            if let shapeLayer = gradientLayer.mask as? CAShapeLayer {
                shapeLayer.path = createHexagonPath().cgPath
            }
        }
        
        // Position dot and number
        let centerX = bounds.width / 2
        dotView.frame = CGRect(x: centerX - 10, y: bounds.height * 0.25, width: 6, height: 6)
        numberLabel.frame = CGRect(x: centerX, y: bounds.height * 0.23, width: 20, height: 30)
        numberLabel.center.x = centerX + 5
        
        // Position title and subtitle
        tLabel.sizeToFit()
        tLabel.center.x = centerX
        tLabel.frame.origin.y = bounds.height * 0.5
        
        subLabel.sizeToFit()
        subLabel.center.x = centerX
        subLabel.frame.origin.y = tLabel.frame.maxY + 2
    }
    
    private func createHexagonPath() -> UIBezierPath {
        // Use the roundedPolygonPath function
        let lineWidth: CGFloat = 0  // Set to 0 for no border or adjust as needed
        let sides = 6  // Hexagon
        let rotationOffset = CGFloat(0)  // Adjust if needed to rotate the hexagon
        
        return roundedPolygonPath(
            rect: bounds,
            lineWidth: lineWidth,
            sides: sides,
            cornerRadius: cornerRadius,
            rotationOffset: rotationOffset
        )
    }
    
    // Set content for the button
    func configure(number: String, title: String, subtitle: String) {
        numberLabel.text = number
        tLabel.text = title
        subLabel.text = subtitle
        setNeedsLayout()
    }
}

// Include the roundedPolygonPath function from your code
public func roundedPolygonPath(rect: CGRect, lineWidth: CGFloat, sides: NSInteger, cornerRadius: CGFloat, rotationOffset: CGFloat = 0) -> UIBezierPath {
    let path = UIBezierPath()
    let theta: CGFloat = CGFloat(2.0 * Double.pi) / CGFloat(sides) // How much to turn at every corner
    let width = min(rect.size.width, rect.size.height)        // Width of the square
    
    let center = CGPoint(x: rect.origin.x + width / 2.0, y: rect.origin.y + width / 2.0)
    
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
    
    // Move the path to the correct origins
    let bounds = path.bounds
    let transform = CGAffineTransform(translationX: -bounds.origin.x + rect.origin.x + lineWidth / 2.0, y: -bounds.origin.y + rect.origin.y + lineWidth / 2.0)
    path.apply(transform)
    
    return path
}
