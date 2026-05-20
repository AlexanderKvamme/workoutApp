//
//  InfiniteExerciseGridViewController.swift
//  workoutApp
//
//  Created by Claude Code on 16/02/2026.
//  Copyright © 2026 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT

class InfiniteExerciseGridViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - Properties
    private let muscle: Muscle?
    private var exercises: [Exercise] = []

    private var scrollView: UIScrollView!
    private var containerView: UIView!

    // Grid configuration (same as HoneycombGridView)
    private let hexagonSize: CGFloat = UIScreen.main.bounds.width / 3
    private let spacing: CGFloat = 2

    // Track which hexView belongs to which coord (so taps work)
    private var visibleHexagons: [HexCoord: HexagonItemView<Exercise>] = [:]
    private var hexViewToCoord: [ObjectIdentifier: HexCoord] = [:]

    // View pooling
    private var hexagonPool: [HexagonItemView<Exercise>] = []
    private let maxPoolSize = 100

    // MARK: - Initialization
    init(muscle: Muscle?) {
        self.muscle = muscle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akDark

        if let muscle = muscle {
            exercises = DatabaseFacade.fetchExercises(containing: muscle) ?? []
        } else {
            exercises = DatabaseFacade.fetchAllExercises()
        }

        setupScrollView()
        setupNavigationBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Initial load after layout is ready
        updateVisibleHexagons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        globalTabBar.hideIt()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        globalTabBar.showIt()
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        title = muscle?.getName() ?? "All Exercises"
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private func setupScrollView() {
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.delegate = self
        scrollView.backgroundColor = .akDark
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Very large content size — user can never realistically reach the edge
        let contentSize: CGFloat = 500_000
        scrollView.contentSize = CGSize(width: contentSize, height: contentSize)

        // Start scrolled to the center
        scrollView.contentOffset = CGPoint(
            x: (contentSize - view.bounds.width) / 2,
            y: (contentSize - view.bounds.height) / 2
        )

        view.addSubview(scrollView)

        containerView = UIView(frame: CGRect(origin: .zero, size: scrollView.contentSize))
        containerView.backgroundColor = .clear
        scrollView.addSubview(containerView)
    }

    // MARK: - Infinite Exercise Mapping
    //
    // Key insight: ANY hex coordinate maps to an exercise via hash % count.
    // This makes the grid infinite — there is always an exercise at every position.
    //
    private func exercise(at coord: HexCoord) -> Exercise {
        guard !exercises.isEmpty else { fatalError("No exercises loaded") }
        // Mix the coordinates with prime numbers to get good distribution
        let hash = abs(coord.q &* 73_856_093 ^ coord.r &* 19_349_663)
        return exercises[hash % exercises.count]
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateVisibleHexagons()
    }

    // MARK: - Hexagon Management
    private func updateVisibleHexagons() {
        guard let scrollView = scrollView, let containerView = containerView else { return }
        guard scrollView.bounds.width > 0, scrollView.bounds.height > 0 else { return }
        guard !exercises.isEmpty else { return }

        // The center of the scroll canvas in content coordinates
        let canvasCenter = CGPoint(
            x: scrollView.contentSize.width / 2,
            y: scrollView.contentSize.height / 2
        )

        // Current visible rect in content coordinates
        let visibleRect = CGRect(
            x: scrollView.contentOffset.x,
            y: scrollView.contentOffset.y,
            width: scrollView.bounds.width,
            height: scrollView.bounds.height
        )

        // Expand by a buffer so hexagons pop in just off-screen
        let buffer: CGFloat = hexagonSize * 2
        let loadRect = visibleRect.insetBy(dx: -buffer, dy: -buffer)

        // Find all hex coords whose pixel position falls within loadRect
        let visibleCoords = allHexCoords(in: loadRect, canvasCenter: canvasCenter)

        // Remove hexagons that scrolled out
        let toRemove = Set(visibleHexagons.keys).subtracting(visibleCoords)
        for coord in toRemove {
            if let hexView = visibleHexagons.removeValue(forKey: coord) {
                hexViewToCoord.removeValue(forKey: ObjectIdentifier(hexView))
                hexView.removeFromSuperview()
                recycleHexagonView(hexView)
            }
        }

        // Add hexagons for newly visible coords
        for coord in visibleCoords where visibleHexagons[coord] == nil {
            let exercise = exercise(at: coord)
            let hexView = getOrCreateHexagonView()

            let position = hexCoordToPixel(coord)
            hexView.frame = CGRect(
                x: canvasCenter.x + position.x - hexagonSize / 2,
                y: canvasCenter.y + position.y - hexagonSize / 2,
                width: hexagonSize,
                height: hexagonSize
            )

            hexView.configure(withItem: exercise, log: nil)

            containerView.addSubview(hexView)
            visibleHexagons[coord] = hexView
            hexViewToCoord[ObjectIdentifier(hexView)] = coord
        }
    }

    // Return all hex grid coordinates visible in the given rect
    private func allHexCoords(in rect: CGRect, canvasCenter: CGPoint) -> Set<HexCoord> {
        var coords = Set<HexCoord>()

        let width = hexagonSize
        let height = width * 0.866
        let hSpacing = (width + spacing) * 0.75
        let vSpacing = height + spacing

        // Convert screen rect to "hex world" coordinates
        let worldMinX = rect.minX - canvasCenter.x
        let worldMaxX = rect.maxX - canvasCenter.x
        let worldMinY = rect.minY - canvasCenter.y
        let worldMaxY = rect.maxY - canvasCenter.y

        // Rough q/r range to search (add padding)
        let qMin = Int(floor(worldMinX / hSpacing)) - 1
        let qMax = Int(ceil(worldMaxX / hSpacing)) + 1
        let rMin = Int(floor(worldMinY / vSpacing)) - 1
        let rMax = Int(ceil(worldMaxY / vSpacing)) + 1

        for q in qMin...qMax {
            for r in rMin...rMax {
                let coord = HexCoord(q: q, r: r)
                let pos = hexCoordToPixel(coord)
                let hexRect = CGRect(
                    x: canvasCenter.x + pos.x - hexagonSize / 2,
                    y: canvasCenter.y + pos.y - hexagonSize / 2,
                    width: hexagonSize,
                    height: hexagonSize
                )
                if rect.intersects(hexRect) {
                    coords.insert(coord)
                }
            }
        }

        return coords
    }

    // MARK: - Coordinate Conversion (same formula as HoneycombGridView)
    private func hexCoordToPixel(_ coord: HexCoord) -> CGPoint {
        let width = hexagonSize
        let height = width * 0.866
        let hSpacing = width + spacing
        let vSpacing = height + spacing

        let x = CGFloat(coord.q) * hSpacing * 0.75
        let y = CGFloat(coord.q) * vSpacing * 0.5 + CGFloat(coord.r) * vSpacing

        return CGPoint(x: x, y: y)
    }

    // MARK: - View Pooling
    private func getOrCreateHexagonView() -> HexagonItemView<Exercise> {
        if let pooled = hexagonPool.popLast() {
            return pooled
        }
        let hexView = HexagonItemView<Exercise>(frame: CGRect(x: 0, y: 0, width: hexagonSize, height: hexagonSize))
        let tap = UITapGestureRecognizer(target: self, action: #selector(hexagonTapped(_:)))
        hexView.addGestureRecognizer(tap)
        return hexView
    }

    private func recycleHexagonView(_ hexView: HexagonItemView<Exercise>) {
        if hexagonPool.count < maxPoolSize {
            hexagonPool.append(hexView)
        }
    }

    @objc private func hexagonTapped(_ sender: UITapGestureRecognizer) {
        guard let hexView = sender.view as? HexagonItemView<Exercise> else { return }
        guard let coord = hexViewToCoord[ObjectIdentifier(hexView)] else { return }
        let ex = exercise(at: coord)
        print("Tapped: \(ex.getName())")
    }

    // MARK: - HexCoord
    private struct HexCoord: Hashable {
        let q: Int
        let r: Int
    }
}
