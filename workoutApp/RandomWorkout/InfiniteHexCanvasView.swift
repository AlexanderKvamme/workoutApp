//
//  InfiniteHexCanvasView.swift
//  workoutApp
//
//  Created by Claude Code on 16/02/2026.
//  Copyright © 2026 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT

class InfiniteHexCanvasView: UIView {

    // MARK: - Configuration
    private let hexagonSize: CGFloat = UIScreen.main.bounds.width / 4
    private let spacing: CGFloat = 4

    // MARK: - Data
    private var exercises: [Exercise] = []
    private var exerciseToCoordMap: [String: HexCoord] = [:]  // Exercise name → hex coord

    // MARK: - Viewport State
    private var viewportCenter: CGPoint = .zero  // In pixel coordinates
    private var panGesture: UIPanGestureRecognizer!

    // MARK: - View Pool
    private var visibleHexagons: [HexCoord: HexagonItemView<Exercise>] = [:]
    private var hexagonPool: [HexagonItemView<Exercise>] = []
    private let maxPoolSize = 50

    // MARK: - Display Link for smooth updates
    private var displayLink: CADisplayLink?
    private var needsUpdate = false

    // MARK: - Callbacks
    var onExerciseSelected: ((Exercise) -> Void)?

    // MARK: - Initialization
    init(exercises: [Exercise]) {
        self.exercises = exercises
        super.init(frame: .zero)

        backgroundColor = .akDark
        generateExerciseCoordinates()
        setupGestures()

        // Trigger initial render
        needsUpdate = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFired))
            displayLink?.add(to: .main, forMode: .common)
        } else {
            displayLink?.invalidate()
            displayLink = nil
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if needsUpdate {
            updateVisibleHexagons()
        }
    }

    @objc private func displayLinkFired() {
        if needsUpdate {
            updateVisibleHexagons()
            needsUpdate = false
        }
    }

    // MARK: - Exercise → Coordinate Mapping
    private func generateExerciseCoordinates() {
        // Deterministically map each exercise to a unique (q, r) coordinate
        // Use spiral pattern starting from (0,0)

        let spiralCoords = generateSpiralHexCoordinates(count: exercises.count)

        for (index, exercise) in exercises.enumerated() {
            let coord = spiralCoords[index]
            exerciseToCoordMap[exercise.getName()] = coord
        }
    }

    // MARK: - Gesture Handling
    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)

        // Move viewport center (inverse of pan direction)
        viewportCenter.x -= translation.x
        viewportCenter.y -= translation.y

        gesture.setTranslation(.zero, in: self)

        // Flag for update on next display link
        needsUpdate = true
    }

    // MARK: - Rendering Logic
    private func updateVisibleHexagons() {
        guard bounds.width > 0 && bounds.height > 0 else { return }

        // 1. Calculate which hex coordinates are visible
        let visibleCoords = calculateVisibleHexCoords()

        // 2. Remove hexagons that are no longer visible
        let coordsToRemove = Set(visibleHexagons.keys).subtracting(visibleCoords)
        for coord in coordsToRemove {
            if let hexView = visibleHexagons.removeValue(forKey: coord) {
                hexView.removeFromSuperview()
                recycleHexagonView(hexView)
            }
        }

        // 3. Add hexagons for newly visible coordinates
        for coord in visibleCoords {
            if visibleHexagons[coord] == nil {
                if let exercise = getExercise(at: coord) {
                    let hexView = getOrCreateHexagonView()
                    configureHexagon(hexView, for: exercise, at: coord)
                    addSubview(hexView)
                    visibleHexagons[coord] = hexView
                }
            }
        }

        // 4. Update positions and scales for all visible hexagons
        updateHexagonTransforms()
    }

    private func calculateVisibleHexCoords() -> Set<HexCoord> {
        var visible = Set<HexCoord>()

        // Calculate dimensions
        let width = hexagonSize
        let height = width * 0.866
        let horizontalSpacing = width + spacing
        let verticalSpacing = height + spacing

        // Convert screen bounds to hex coordinate range (with buffer)
        let buffer: CGFloat = 2 * hexagonSize  // Show hexagons beyond screen edge

        let minX = viewportCenter.x - buffer
        let maxX = viewportCenter.x + bounds.width + buffer
        let minY = viewportCenter.y - buffer
        let maxY = viewportCenter.y + bounds.height + buffer

        // Estimate q, r ranges (approximate)
        let qRange = Int((maxX - minX) / (horizontalSpacing * 0.75)) + 2
        let rRange = Int((maxY - minY) / verticalSpacing) + 2

        let centerQ = Int(viewportCenter.x / (horizontalSpacing * 0.75))
        let centerR = Int(viewportCenter.y / verticalSpacing)

        // Generate hex coords in estimated visible range
        for q in (centerQ - qRange)...(centerQ + qRange) {
            for r in (centerR - rRange)...(centerR + rRange) {
                let coord = HexCoord(q: q, r: r)
                let pixelPos = hexCoordToPixel(coord)

                // Check if this hex coord is actually visible (within buffer range)
                if pixelPos.x >= minX && pixelPos.x <= maxX &&
                   pixelPos.y >= minY && pixelPos.y <= maxY {
                    visible.insert(coord)
                }
            }
        }

        return visible
    }

    private func updateHexagonTransforms() {
        let screenCenter = CGPoint(x: bounds.width / 2, y: bounds.height / 2)

        for (coord, hexView) in visibleHexagons {
            let hexPixelPos = hexCoordToPixel(coord)

            // Position relative to viewport
            let screenPos = CGPoint(
                x: hexPixelPos.x - viewportCenter.x,
                y: hexPixelPos.y - viewportCenter.y
            )

            // Center the hexagon on its position
            hexView.center = screenPos

            // Calculate distance from screen center
            let dx = screenPos.x - screenCenter.x
            let dy = screenPos.y - screenCenter.y
            let distanceFromCenter = sqrt(dx * dx + dy * dy)

            // Max distance is from center to corner of screen
            let maxDistance = sqrt(pow(bounds.width / 2, 2) + pow(bounds.height / 2, 2))

            // Scale: 1.0 at center, 0.6 at edges
            let normalizedDistance = min(1.0, distanceFromCenter / maxDistance)
            let scale = 1.0 - (normalizedDistance * 0.4)  // 1.0 → 0.6

            // Alpha: 1.0 at center, 0.3 at edges
            let alpha = 1.0 - (normalizedDistance * 0.7)  // 1.0 → 0.3

            hexView.transform = CGAffineTransform(scaleX: scale, y: scale)
            hexView.alpha = alpha
        }
    }

    // MARK: - Coordinate Conversion
    private func hexCoordToPixel(_ coord: HexCoord) -> CGPoint {
        let width = hexagonSize
        let height = width * 0.866
        let horizontalSpacing = width + spacing
        let verticalSpacing = height + spacing

        // Axial to pixel conversion (same as HoneycombGridView)
        let x = CGFloat(coord.q) * horizontalSpacing * 0.75
        let y = CGFloat(coord.q) * verticalSpacing * 0.5 + CGFloat(coord.r) * verticalSpacing

        return CGPoint(x: x, y: y)
    }

    // MARK: - Exercise Lookup
    private func getExercise(at coord: HexCoord) -> Exercise? {
        // Find exercise mapped to this coordinate
        for (name, mappedCoord) in exerciseToCoordMap {
            if mappedCoord == coord {
                return exercises.first { $0.getName() == name }
            }
        }
        return nil
    }

    // MARK: - View Pooling
    private func getOrCreateHexagonView() -> HexagonItemView<Exercise> {
        if let pooled = hexagonPool.popLast() {
            return pooled
        }

        let hexView = HexagonItemView<Exercise>(frame: CGRect(x: 0, y: 0, width: hexagonSize, height: hexagonSize))

        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hexagonTapped(_:)))
        hexView.addGestureRecognizer(tapGesture)

        return hexView
    }

    @objc private func hexagonTapped(_ sender: UITapGestureRecognizer) {
        guard let hexView = sender.view as? HexagonItemView<Exercise> else { return }

        // Get the coordinate from the tag
        let tag = hexView.tag
        let q = tag / 10000
        let r = tag % 10000

        let coord = HexCoord(q: q, r: r)

        // Find the exercise at this coordinate
        if let exercise = getExercise(at: coord) {
            onExerciseSelected?(exercise)
        }
    }

    private func recycleHexagonView(_ hexView: HexagonItemView<Exercise>) {
        if hexagonPool.count < maxPoolSize {
            hexagonPool.append(hexView)
        }
    }

    private func configureHexagon(_ hexView: HexagonItemView<Exercise>,
                                  for exercise: Exercise,
                                  at coord: HexCoord) {
        hexView.configure(withItem: exercise, log: nil)
        hexView.frame.size = CGSize(width: hexagonSize, height: hexagonSize)

        // Store coordinate in tag for tap handling
        hexView.tag = coord.q * 10000 + coord.r
    }

    // MARK: - Helper Structs

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

    // MARK: - Spiral Generation

    private func generateSpiralHexCoordinates(count: Int) -> [HexCoord] {
        guard count > 0 else { return [] }

        var coordinates: [HexCoord] = []
        var visited = Set<HexCoord>()

        // Start with center hexagon
        let center = HexCoord(q: 0, r: 0)
        coordinates.append(center)
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

                coordinates.append(hex)
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
}
