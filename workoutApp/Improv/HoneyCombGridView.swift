import UIKit
import AKKIT

// MARK: - Reusable HoneycombGridView
class HoneycombGridView<T>: UIView {
    // Configuration
    private let hexagonSize: CGFloat
    private let spacing: CGFloat
    private var items: [T] = []
    private var textProvider: (T) -> String
    private var onItemSelected: ((T, HexagonItemView) -> Void)?
    private var onItemLongPressed: ((T, HexagonItemView) -> Void)?
    private var needsLayout = true
    
    // Store hexagon views and their positions for lookup
    private var hexagonViews: [Int: HexagonItemView] = [:]
    
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
    
    // Configure the grid with data and selection handlers
    func configure(with items: [T],
                  onItemSelected: @escaping (T, HexagonItemView) -> Void,
                  onItemLongPressed: ((T, HexagonItemView) -> Void)? = nil) {
        self.items = items
        self.onItemSelected = onItemSelected
        self.onItemLongPressed = onItemLongPressed
        
        // Clear existing content
        subviews.forEach { $0.removeFromSuperview() }
        hexagonViews.removeAll()
        
        // Mark for layout update
        needsLayout = true
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if needsLayout && bounds.width > 0 && bounds.height > 0 {
            createHoneycombGrid()
            needsLayout = false
        }
    }
    
    // NEW METHOD: Get the center position of a cell for a specific item
    func getCellCenterPosition(for item: T) -> CGPoint? {
        // Find the index of the item
        guard let index = items.firstIndex(where: { $0 as AnyObject === item as AnyObject }) else {
            return nil
        }
        
        // Get the hexagon view for this index
        guard let hexView = hexagonViews[index] else {
            return nil
        }
        
        // Convert the center of the hexagon to the window's coordinate space
        let centerInHexView = CGPoint(x: hexView.bounds.midX, y: hexView.bounds.midY)
        return hexView.convert(centerInHexView, to: nil)
    }
    
    // NEW METHOD: Get both the item and its cell center position
    func getItemAndCellCenter(at index: Int) -> (item: T, center: CGPoint)? {
        guard index >= 0 && index < items.count, let hexView = hexagonViews[index] else {
            return nil
        }
        
        let item = items[index]
        let centerInHexView = CGPoint(x: hexView.bounds.midX, y: hexView.bounds.midY)
        let centerInWindow = hexView.convert(centerInHexView, to: nil)
        
        return (item, centerInWindow)
    }
    
    private func createHoneycombGrid() {
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
            return
        }
        
        // Calculate container size
        let containerWidth = max(maxX - minX, width) // Ensure minimum width
        let containerHeight = max(maxY - minY, height) // Ensure minimum height
        
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
            
            // Store the hexagon view for later lookup
            hexagonViews[index] = hexView
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
        
        // Configure stripes - 3 stripes by default
//        hexView.configureStripes(
//            count: 3,
//            color: .white,
//            width: 6.0,
//            spacing: hexagonSize / 6, // Space them evenly
//            angle: .pi / 4,
//            inset: 0.2
//        )
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hexagonTapped(_:)))
        hexView.addGestureRecognizer(tapGesture)
        
        // Add long press gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(hexagonLongPressed(_:)))
        longPressGesture.minimumPressDuration = 0.1 // Start quickly for visual feedback
        hexView.isMultipleTouchEnabled = true
        hexView.addGestureRecognizer(longPressGesture)
        
        hexView.tag = index
        
        // Set the long press completion handler
        hexView.setLongPressAction { [weak self] in
            guard let self = self,
                  let onItemLongPressed = self.onItemLongPressed,
                  index >= 0 && index < self.items.count else { return }
            
            let selectedItem = self.items[index]
            onItemLongPressed(selectedItem, hexView)
        }
        
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
        print("bam selected will be called in 0.2")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.onItemSelected?(selectedItem, hexView)
        }
    }
    
    @objc private func hexagonLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard let hexView = sender.view as? HexagonItemView else { return }
        
        print("hexagonLongPressed")
        
        switch sender.state {
        case .began:
            hexView.startLongPressAnimation()
        case .ended, .cancelled, .failed:
            hexView.cancelLongPressAnimation()
        default:
            break
        }
    }
}
