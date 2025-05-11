import UIKit

class StarView: UIView {
    
    private let starColor = UIColor(hexString: "#FFA500") // Orange color
    var cornerRadius: CGFloat = 50.0 {
        didSet {
            updateStarPath()
        }
    }
    
    private let starLayer = CAShapeLayer()
    
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
        
        // Configure the shape layer
        starLayer.fillColor = starColor.cgColor
        starLayer.strokeColor = starColor.cgColor // Same color for stroke
        starLayer.lineJoin = .round // This is key for rounded corners
        layer.addSublayer(starLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateStarPath()
    }
    
    private func updateStarPath() {
        // Create the star path
        let starPath = createStarPath()
        
        // Set the line width based on the corner radius
        starLayer.lineWidth = cornerRadius
        
        // Apply the path to the shape layer
        starLayer.path = starPath.cgPath
        starLayer.frame = bounds
    }
    
    private func createStarPath() -> UIBezierPath {
        // Adjust the radius to account for the stroke width
        let adjustedRadius = min(bounds.width, bounds.height) / 2 - cornerRadius / 2
        
        let path = UIBezierPath()
        let centerX = bounds.width / 2
        let centerY = bounds.height / 2
        
        // Calculate the points of a 5-pointed star
        var points: [CGPoint] = []
        
        for i in 0..<10 {
            let angle = CGFloat(i) * .pi / 5 - .pi / 2
            let pointRadius = i % 2 == 0 ? adjustedRadius : adjustedRadius * 0.4
            
            let x = centerX + pointRadius * cos(angle)
            let y = centerY + pointRadius * sin(angle)
            
            points.append(CGPoint(x: x, y: y))
        }
        
        // Create the star path
        if points.count > 0 {
            path.move(to: points[0])
            
            for i in 1..<points.count {
                path.addLine(to: points[i])
            }
            
            path.close()
        }
        
        return path
    }
}
