import UIKit
import AKKIT

//class HoneycombViewController: SelectionViewController {
//    
//    // Configuration
//    private let hexagonSize: CGFloat = UIScreen.main.bounds.width/3
//    private let spacing: CGFloat = 2 // Small gap between hexagons
//    
//    // Data source
//    private var muscleGroups: [Muscle] = []
//    
//    init() {
//        super.init(header: SelectionViewHeader(header: "Improv", subheader: "Today"))
//    }
//    
//    @MainActor required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .akLight
//        
//        // Get data from database
//        muscleGroups = DatabaseFacade.fetchMuscles()
//        let muscleNames = muscleGroups.map { $0.name ?? "NA" }
//        print("bam muscles: ", muscleNames)
//        
//        createHoneycombGrid()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // Hide the navigation bar
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//        print("will see if custom")
//        if let customTabBarController = self.tabBarController as? CustomTabBarController {
//            print("had custom")
//            customTabBarController.hideSelectionIndicator(shouldAnimate: true)
//            navigationController?.setNavigationBarHidden(true, animated: true)
//        }
//    }
//    
//    private func createHoneycombGrid() {
//        // Basic measurements
//        let width = hexagonSize
//        let height = width * 0.866 // height of a hexagon (sqrt(3)/2 * width)
//        
//        // For a perfect tessellation with a small gap
//        let horizontalSpacing = width + spacing
//        let verticalSpacing = height + spacing
//        
//        // Generate spiral coordinates for a honeycomb pattern
//        let positions = generateSpiralHexCoordinates(count: muscleGroups.count)
//        
//        // Create a container view that will hold all hexagons
//        let containerView = UIView()
//        view.addSubview(containerView)
//        
//        // Add hexagons to the container
//        var minX: CGFloat = .greatestFiniteMagnitude
//        var minY: CGFloat = .greatestFiniteMagnitude
//        var maxX: CGFloat = -.greatestFiniteMagnitude
//        var maxY: CGFloat = -.greatestFiniteMagnitude
//        
//        // First pass: calculate bounds
//        for position in positions {
//            // Convert axial coordinates to pixel coordinates
//            let xPos = (CGFloat(position.q) * horizontalSpacing * 0.75)
//            let yPos = (CGFloat(position.q) * verticalSpacing * 0.5 + CGFloat(position.r) * verticalSpacing)
//            
//            let hexagonX = xPos - width/2
//            let hexagonY = yPos - height/2
//            
//            // Update bounds
//            minX = min(minX, hexagonX)
//            minY = min(minY, hexagonY)
//            maxX = max(maxX, hexagonX + width)
//            maxY = max(maxY, hexagonY + height)
//        }
//        
//        // Calculate container size
//        let containerWidth = maxX - minX
//        let containerHeight = maxY - minY
//        
//        // Second pass: create and position hexagons
//        for (index, position) in positions.enumerated() {
//            // Skip if index is out of bounds
//            guard index < muscleGroups.count else { break }
//            
//            // Convert axial coordinates to pixel coordinates
//            let xPos = (CGFloat(position.q) * horizontalSpacing * 0.75)
//            let yPos = (CGFloat(position.q) * verticalSpacing * 0.5 + CGFloat(position.r) * verticalSpacing)
//            
//            // Position relative to container, adjusting for the minimum bounds
//            let hexagonX = xPos - width/2 - minX
//            let hexagonY = yPos - height/2 - minY
//            
//            let muscleGroup = muscleGroups[index]
//            let hexView = createHexagonView(
//                x: hexagonX,
//                y: hexagonY,
//                index: index,
//                text: muscleGroup.name ?? "Unknown"
//            )
//            
//            containerView.addSubview(hexView)
//        }
//        
//        // Set container size and center it in the view
//        containerView.frame = CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight)
//        containerView.center = CGPoint(
//            x: view.bounds.width / 2,
//            y: view.bounds.height / 2
//        )
//        
//        // If the container is larger than the view, make it scrollable
//        if containerWidth > view.bounds.width || containerHeight > view.bounds.height {
//            // Create a scroll view
//            let scrollView = UIScrollView(frame: view.bounds)
//            scrollView.showsHorizontalScrollIndicator = false
//            scrollView.showsVerticalScrollIndicator = false
//            
//            // Move container to scroll view
//            containerView.removeFromSuperview()
//            scrollView.addSubview(containerView)
//            view.addSubview(scrollView)
//            
//            // Set content size
//            scrollView.contentSize = containerView.frame.size
//            
//            // Center content
//            let xOffset = max(0, (scrollView.contentSize.width - scrollView.bounds.width) / 2)
//            let yOffset = max(0, (scrollView.contentSize.height - scrollView.bounds.height) / 2)
//            scrollView.contentOffset = CGPoint(x: xOffset, y: yOffset)
//        }
//    }
//    
//    // Hexagon coordinates in axial coordinate system (q,r)
//    private struct HexCoord: Hashable {
//        let q: Int
//        let r: Int
//        
//        // Returns the 6 neighbors of this hex in axial coordinates
//        func neighbors() -> [HexCoord] {
//            let directions = [
//                HexCoord(q: 1, r: 0),   // East
//                HexCoord(q: 1, r: -1),  // Northeast
//                HexCoord(q: 0, r: -1),  // Northwest
//                HexCoord(q: -1, r: 0),  // West
//                HexCoord(q: -1, r: 1),  // Southwest
//                HexCoord(q: 0, r: 1)    // Southeast
//            ]
//            
//            return directions.map { HexCoord(q: self.q + $0.q, r: self.r + $0.r) }
//        }
//    }
//    
//    // Generate spiral coordinates for hexagons
//    private func generateSpiralHexCoordinates(count: Int) -> [(q: Int, r: Int, isBlack: Bool)] {
//        guard count > 0 else { return [] }
//        
//        var coordinates: [(q: Int, r: Int, isBlack: Bool)] = []
//        var visited = Set<HexCoord>()
//        
//        // Start with center hexagon
//        let center = HexCoord(q: 0, r: 0)
//        coordinates.append((q: center.q, r: center.r, isBlack: false))
//        visited.insert(center)
//        
//        if count == 1 {
//            return coordinates
//        }
//        
//        // BFS-like approach to generate a spiral
//        var queue = center.neighbors()
//        
//        while coordinates.count < count {
//            var nextRingNeighbors = [HexCoord]()
//            
//            // Process current ring
//            for hex in queue {
//                if visited.contains(hex) {
//                    continue
//                }
//                
//                // Alternate black and white based on position
//                let isBlack = (coordinates.count % 2 == 1)
//                coordinates.append((q: hex.q, r: hex.r, isBlack: isBlack))
//                visited.insert(hex)
//                
//                // Break if we've reached the requested count
//                if coordinates.count >= count {
//                    break
//                }
//                
//                // Collect neighbors for the next ring
//                for neighbor in hex.neighbors() {
//                    if !visited.contains(neighbor) && !nextRingNeighbors.contains(neighbor) {
//                        nextRingNeighbors.append(neighbor)
//                    }
//                }
//            }
//            
//            // Sort neighbors to maintain a spiral pattern
//            nextRingNeighbors.sort { a, b in
//                let angleA = atan2(Double(a.r), Double(a.q))
//                let angleB = atan2(Double(b.r), Double(b.q))
//                return angleA < angleB
//            }
//            
//            queue = nextRingNeighbors
//        }
//        
//        return coordinates
//    }
//    
//    // Create a custom UIView for the hexagon that handles its own touch events
//    private func createHexagonView(x: CGFloat, y: CGFloat, index: Int, text: String) -> HexagonView {
//        let hexView = HexagonView(frame: CGRect(x: x, y: y, width: hexagonSize, height: hexagonSize))
//        hexView.configure(withText: text, index: index)
//        hexView.delegate = self
//        return hexView
//    }
//    
//    private func createHexagonPath(size: CGFloat) -> UIBezierPath {
//        let path = UIBezierPath()
//        let center = CGPoint(x: size/2, y: size/2)
//        let radius = size/2 - 2 // Smaller radius to prevent overlap
//        let cornerRadius: CGFloat = 10
//        let cornerInset = cornerRadius
//
//        // Calculate points of the hexagon
//        var points: [CGPoint] = []
//        for i in 0..<6 {
//            let angle = CGFloat(i) * (CGFloat.pi / 3)
//            let point = CGPoint(
//                x: center.x + radius * cos(angle),
//                y: center.y + radius * sin(angle)
//            )
//            points.append(point)
//        }
//        
//        // Create a hexagon with rounded corners (straight sides)
//        for i in 0..<6 {
//            let currentPoint = points[i]
//            let nextPoint = points[(i + 1) % 6]
//            
//            // Calculate direction vectors
//            let dx1 = currentPoint.x - points[(i + 5) % 6].x
//            let dy1 = currentPoint.y - points[(i + 5) % 6].y
//            let len1 = sqrt(dx1*dx1 + dy1*dy1)
//            
//            let dx2 = nextPoint.x - currentPoint.x
//            let dy2 = nextPoint.y - currentPoint.y
//            let len2 = sqrt(dx2*dx2 + dy2*dy2)
//            
//            // Inset points from the vertex
//            let insetPoint1 = CGPoint(
//                x: currentPoint.x - (dx1 / len1) * cornerInset,
//                y: currentPoint.y - (dy1 / len1) * cornerInset
//            )
//            
//            let insetPoint2 = CGPoint(
//                x: currentPoint.x + (dx2 / len2) * cornerInset,
//                y: currentPoint.y + (dy2 / len2) * cornerInset
//            )
//            
//            // First point or continuing the path
//            if i == 0 {
//                path.move(to: insetPoint1)
//            } else {
//                path.addLine(to: insetPoint1)
//            }
//            
//            // Add the rounded corner
//            path.addQuadCurve(to: insetPoint2, controlPoint: currentPoint)
//            
//            // Add the straight line to the next corner
//            if i < 5 {
//                path.addLine(to: CGPoint(
//                    x: nextPoint.x - (dx2 / len2) * cornerInset,
//                    y: nextPoint.y - (dy2 / len2) * cornerInset
//                ))
//            }
//        }
//        
//        path.close()
//        return path
//    }
//    
//    func handleHexagonTapped(at index: Int) {
//        print("Hexagon tapped at index: \(index)")
//        
//        // Make sure the index is valid
//        guard index >= 0 && index < muscleGroups.count else {
//            print("Invalid muscle group index")
//            return
//        }
//        
//        // Get the selected muscle group
//        let selectedMuscleGroup = muscleGroups[index]
//        print("Selected muscle group: \(selectedMuscleGroup.name ?? "Unknown")")
//        
//        // Navigate to the ImprovWorkoutController with the selected muscle group
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
//            print("Navigating to ImprovWorkoutController")
//            let improvWorkoutController = ImprovWorkoutController(muscleGroup: selectedMuscleGroup)
//            self?.navigationController?.pushViewController(improvWorkoutController, animated: true)
//        }
//    }
//}
//
//// MARK: - HexagonView
//protocol HexagonViewDelegate: AnyObject {
//    func handleHexagonTapped(at index: Int)
//}
//
//class HexagonView: UIView {
//    private var index: Int = 0
//    private var hexagonLayer: CAShapeLayer?
//    weak var delegate: HexagonViewDelegate?
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        isUserInteractionEnabled = true
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func configure(withText text: String, index: Int) {
//        self.index = index
//        
//        // Clear any existing layers
//        layer.sublayers?.removeAll()
//        subviews.forEach { $0.removeFromSuperview() }
//        
//        // Create hexagon shape
//        let hexagonLayer = CAShapeLayer()
//        hexagonLayer.path = createHexagonPath().cgPath
//        hexagonLayer.fillColor = UIColor.black.cgColor
//        layer.addSublayer(hexagonLayer)
//        self.hexagonLayer = hexagonLayer
//        
//        // Add text label
//        let textLabel = UILabel()
//        textLabel.frame = bounds.insetBy(dx: bounds.width * 0.15, dy: bounds.height * 0.15)
//        textLabel.text = text
//        textLabel.textColor = .white
//        textLabel.textAlignment = .center
//        textLabel.font = AKFont.round(.bold, 16)
//        textLabel.numberOfLines = 0
//        textLabel.adjustsFontSizeToFitWidth = true
//        textLabel.minimumScaleFactor = 0.5
//        addSubview(textLabel)
//    }
//    
//    private func createHexagonPath() -> UIBezierPath {
//        let size = bounds.width
//        let path = UIBezierPath()
//        let center = CGPoint(x: size/2, y: size/2)
//        let radius = size/2 - 2
//        let cornerRadius: CGFloat = 10
//        let cornerInset = cornerRadius
//        
//        // Calculate points of the hexagon
//        var points: [CGPoint] = []
//        for i in 0..<6 {
//            let angle = CGFloat(i) * (CGFloat.pi / 3)
//            let point = CGPoint(
//                x: center.x + radius * cos(angle),
//                y: center.y + radius * sin(angle)
//            )
//            points.append(point)
//        }
//        
//        // Create a hexagon with rounded corners
//        for i in 0..<6 {
//            let currentPoint = points[i]
//            let nextPoint = points[(i + 1) % 6]
//            
//            // Calculate direction vectors
//            let dx1 = currentPoint.x - points[(i + 5) % 6].x
//            let dy1 = currentPoint.y - points[(i + 5) % 6].y
//            let len1 = sqrt(dx1*dx1 + dy1*dy1)
//            
//            let dx2 = nextPoint.x - currentPoint.x
//            let dy2 = nextPoint.y - currentPoint.y
//            let len2 = sqrt(dx2*dx2 + dy2*dy2)
//            
//            // Inset points from the vertex
//            let insetPoint1 = CGPoint(
//                x: currentPoint.x - (dx1 / len1) * cornerInset,
//                y: currentPoint.y - (dy1 / len1) * cornerInset
//            )
//            
//            let insetPoint2 = CGPoint(
//                x: currentPoint.x + (dx2 / len2) * cornerInset,
//                y: currentPoint.y + (dy2 / len2) * cornerInset
//            )
//            
//            // First point or continuing the path
//            if i == 0 {
//                path.move(to: insetPoint1)
//            } else {
//                path.addLine(to: insetPoint1)
//            }
//            
//            // Add the rounded corner
//            path.addQuadCurve(to: insetPoint2, controlPoint: currentPoint)
//            
//            // Add the straight line to the next corner
//            if i < 5 {
//                path.addLine(to: CGPoint(
//                    x: nextPoint.x - (dx2 / len2) * cornerInset,
//                    y: nextPoint.y - (dy2 / len2) * cornerInset
//                ))
//            }
//        }
//        
//        path.close()
//        return path
//    }
//    
//    // Handle touch events
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        animateHighlight(true)
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        animateHighlight(false)
//        
//        // Check if touch is inside the view
//        if let touch = touches.first {
//            let location = touch.location(in: self)
//            if bounds.contains(location) {
//                print("Touch ended inside hexagon at index: \(index)")
//                delegate?.handleHexagonTapped(at: index)
//            }
//        }
//    }
//    
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        animateHighlight(false)
//    }
//    
//    private func animateHighlight(_ highlighted: Bool) {
//        guard let hexagonLayer = hexagonLayer else { return }
//        
//        let toColor = highlighted ? UIColor.systemBlue.cgColor : UIColor.black.cgColor
//        
//        let animation = CABasicAnimation(keyPath: "fillColor")
//        animation.fromValue = hexagonLayer.fillColor
//        animation.toValue = toColor
//        animation.duration = 0.2
//        hexagonLayer.add(animation, forKey: "fillColor")
//        hexagonLayer.fillColor = toColor
//    }
//}
//
//// MARK: - HexagonViewDelegate
//extension HoneycombViewController: HexagonViewDelegate {}
//
