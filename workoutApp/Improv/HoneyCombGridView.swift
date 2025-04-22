import UIKit
import AKKIT

// MARK: - Reusable HoneycombGridView
class HoneycombGridView<T>: UIView {
    // Configuration
    private let hexagonSize: CGFloat
    private let spacing: CGFloat
    private var items: [T] = []
    private var textProvider: (T) -> String
    private var onItemSelected: ((T) -> Void)?
    private var needsLayout = true
    
    // Initializer with configuration options
    init(hexagonSize: CGFloat = UIScreen.main.bounds.width/3,
         spacing: CGFloat = 2,
         textProvider: @escaping (T) -> String) {
        self.hexagonSize = hexagonSize
        self.spacing = spacing
        self.textProvider = textProvider
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Configure the grid with data and selection handler
    func configure(with items: [T], onItemSelected: @escaping (T) -> Void) {
        self.items = items
        self.onItemSelected = onItemSelected
        
        // Clear existing content
        subviews.forEach { $0.removeFromSuperview() }
        
        // Mark for layout update
        needsLayout = true
        setNeedsLayout()
        
        print("Configured honeycomb with \(items.count) items")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if needsLayout && bounds.width > 0 && bounds.height > 0 {
            print("Laying out honeycomb grid with bounds: \(bounds)")
            createHoneycombGrid()
            needsLayout = false
        }
    }
    
    private func createHoneycombGrid() {
        print("Creating honeycomb grid with \(items.count) items")
        
        // Basic measurements
        let width = hexagonSize
        let height = width * 0.866 // height of a hexagon (sqrt(3)/2 * width)
        
        // For a perfect tessellation with a small gap
        let horizontalSpacing = width + spacing
        let verticalSpacing = height + spacing
        
        // Generate spiral coordinates for a honeycomb pattern
        let positions = generateSpiralHexCoordinates(count: items.count)
        
        // Create a container view that will hold all hexagons
        let containerView = UIView()
        containerView.backgroundColor = .clear
        addSubview(containerView)
        
        // Add hexagons to the container
        var minX: CGFloat = .greatestFiniteMagnitude
        var minY: CGFloat = .greatestFiniteMagnitude
        var maxX: CGFloat = -.greatestFiniteMagnitude
        var maxY: CGFloat = -.greatestFiniteMagnitude
        
        // First pass: calculate bounds
        for position in positions {
            // Convert axial coordinates to pixel coordinates
            let xPos = (CGFloat(position.q) * horizontalSpacing * 0.75)
            let yPos = (CGFloat(position.q) * verticalSpacing * 0.5 + CGFloat(position.r) * verticalSpacing)
            
            let hexagonX = xPos - width/2
            let hexagonY = yPos - height/2
            
            // Update bounds
            minX = min(minX, hexagonX)
            minY = min(minY, hexagonY)
            maxX = max(maxX, hexagonX + width)
            maxY = max(maxY, hexagonY + height)
        }
        
        // Handle the case where there are no items
        if positions.isEmpty {
            print("No positions to display")
            return
        }
        
        // Calculate container size
        let containerWidth = max(maxX - minX, width) // Ensure minimum width
        let containerHeight = max(maxY - minY, height) // Ensure minimum height
        
        print("Container size: \(containerWidth) x \(containerHeight)")
        
        // Second pass: create and position hexagons
        for (index, position) in positions.enumerated() {
            // Skip if index is out of bounds
            guard index < items.count else { break }
            
            // Convert axial coordinates to pixel coordinates
            let xPos = (CGFloat(position.q) * horizontalSpacing * 0.75)
            let yPos = (CGFloat(position.q) * verticalSpacing * 0.5 + CGFloat(position.r) * verticalSpacing)
            
            // Position relative to container, adjusting for the minimum bounds
            let hexagonX = xPos - width/2 - minX
            let hexagonY = yPos - height/2 - minY
            
            let item = items[index]
            let hexView = createHexagonView(
                x: hexagonX,
                y: hexagonY,
                text: textProvider(item),
                index: index
            )
            
            containerView.addSubview(hexView)
            print("Added hexagon at position: \(hexagonX), \(hexagonY) with text: \(textProvider(item))")
        }
        
        // Set container size and center it in the view
        containerView.frame = CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight)
        
        // Center the container in the available space
        if bounds.width > 0 && bounds.height > 0 {
            containerView.center = CGPoint(
                x: bounds.width / 2,
                y: bounds.height / 2
            )
        } else {
            print("Warning: HoneycombGridView has zero bounds: \(bounds)")
        }
        
        // If the container is larger than the view, make it scrollable
        if containerWidth > bounds.width || containerHeight > bounds.height {
            // Create a scroll view
            let scrollView = UIScrollView(frame: bounds)
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.backgroundColor = .clear
            
            // Move container to scroll view
            containerView.removeFromSuperview()
            scrollView.addSubview(containerView)
            addSubview(scrollView)
            
            // Set content size
            scrollView.contentSize = containerView.frame.size
            
            // Center content
            let xOffset = max(0, (scrollView.contentSize.width - scrollView.bounds.width) / 2)
            let yOffset = max(0, (scrollView.contentSize.height - scrollView.bounds.height) / 2)
            scrollView.contentOffset = CGPoint(x: xOffset, y: yOffset)
            
            print("Added scroll view with content size: \(scrollView.contentSize)")
        }
    }
    
    // Hexagon coordinates in axial coordinate system (q,r)
    private struct HexCoord: Hashable {
        let q: Int
        let r: Int
        
        // Returns the 6 neighbors of this hex in axial coordinates
        func neighbors() -> [HexCoord] {
            let directions = [
                HexCoord(q: 1, r: 0),   // East
                HexCoord(q: 1, r: -1),  // Northeast
                HexCoord(q: 0, r: -1),  // Northwest
                HexCoord(q: -1, r: 0),  // West
                HexCoord(q: -1, r: 1),  // Southwest
                HexCoord(q: 0, r: 1)    // Southeast
            ]
            
            return directions.map { HexCoord(q: self.q + $0.q, r: self.r + $0.r) }
        }
    }
    
    // Generate spiral coordinates for hexagons
    private func generateSpiralHexCoordinates(count: Int) -> [(q: Int, r: Int)] {
        guard count > 0 else { return [] }
        
        var coordinates: [(q: Int, r: Int)] = []
        var visited = Set<HexCoord>()
        
        // Start with center hexagon
        let center = HexCoord(q: 0, r: 0)
        coordinates.append((q: center.q, r: center.r))
        visited.insert(center)
        
        if count == 1 {
            return coordinates
        }
        
        // BFS-like approach to generate a spiral
        var queue = center.neighbors()
        
        while coordinates.count < count {
            var nextRingNeighbors = [HexCoord]()
            
            // Process current ring
            for hex in queue {
                if visited.contains(hex) {
                    continue
                }
                
                coordinates.append((q: hex.q, r: hex.r))
                visited.insert(hex)
                
                // Break if we've reached the requested count
                if coordinates.count >= count {
                    break
                }
                
                // Collect neighbors for the next ring
                for neighbor in hex.neighbors() {
                    if !visited.contains(neighbor) && !nextRingNeighbors.contains(neighbor) {
                        nextRingNeighbors.append(neighbor)
                    }
                }
            }
            
            // Sort neighbors to maintain a spiral pattern
            nextRingNeighbors.sort { a, b in
                let angleA = atan2(Double(a.r), Double(a.q))
                let angleB = atan2(Double(b.r), Double(b.q))
                return angleA < angleB
            }
            
            queue = nextRingNeighbors
        }
        
        return coordinates
    }
    
    // Create a custom UIView for the hexagon that handles its own touch events
    private func createHexagonView(x: CGFloat, y: CGFloat, text: String, index: Int) -> HexagonItemView {
        let hexView = HexagonItemView(frame: CGRect(x: x, y: y, width: hexagonSize, height: hexagonSize))
        hexView.configure(withText: text)
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hexagonTapped(_:)))
        hexView.addGestureRecognizer(tapGesture)
        hexView.tag = index
        
        return hexView
    }
    
    @objc private func hexagonTapped(_ sender: UITapGestureRecognizer) {
        guard let hexView = sender.view as? HexagonItemView else { return }
        
        // Get the index and make sure it's valid
        let index = hexView.tag
        guard index >= 0 && index < items.count else { return }
        
        // Provide visual feedback
        hexView.animateHighlight()
        
        // Call the selection handler
        let selectedItem = items[index]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.onItemSelected?(selectedItem)
        }
    }
}

// MARK: - HexagonItemView
class HexagonItemView: UIView {
    private var hexagonLayer: CAShapeLayer?
    private var textLabel: UILabel?
    
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
        
        print("Set up hexagon view with frame: \(frame)")
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
}
