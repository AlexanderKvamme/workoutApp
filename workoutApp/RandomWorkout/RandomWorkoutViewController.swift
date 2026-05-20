//
//  RandomWorkoutViewController.swift
//  workoutApp
//
//  Created by Claude Code on 16/02/2026.
//  Copyright © 2026 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT

class RandomWorkoutViewController: SelectionViewController {

    private var honeycombGrid: HoneycombGridView<Muscle>!
    private var muscles: [Muscle] = []
    private var allButton: UIButton!

    init() {
        super.init(header: AnimatedScreenHeader(header: "Random", subheader: "Workout"))
    }

    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        muscles = DatabaseFacade.fetchMuscles()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reset()
        setupHoneycombGrid()
        setupAllButton()

        globalTabBar.showIt()
        header.play()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        honeycombGrid?.setNeedsLayout()
    }

    // MARK: - Setup

    private func reset() {
        if honeycombGrid != nil {
            honeycombGrid.reset()
            honeycombGrid.removeFromSuperview()
        }
        allButton?.removeFromSuperview()
    }

    private func setupHoneycombGrid() {
        // Create the honeycomb grid with muscle groups
        honeycombGrid = HoneycombGridView<Muscle>(textProvider: { muscle in
            return muscle.name ?? "Unknown"
        })

        view.addSubview(honeycombGrid)
        honeycombGrid.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            honeycombGrid.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            honeycombGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            honeycombGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            honeycombGrid.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.layoutIfNeeded()

        // Configure with muscles - tap opens infinite grid for that muscle
        honeycombGrid.configure(with: muscles) { [weak self] (selectedMuscle, hexView: HexagonItemView) in
            self?.openInfiniteGrid(for: selectedMuscle)
        }
    }

    private func setupAllButton() {
        // Create "All" button styled like a chip
        allButton = UIButton(type: .system)
        allButton.setTitle("All", for: .normal)
        allButton.titleLabel?.font = AKFont.round(.bold, 16)
        allButton.setTitleColor(.akLight, for: .normal)
        allButton.backgroundColor = .black
        allButton.layer.cornerRadius = 16
        allButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        allButton.addTarget(self, action: #selector(allButtonTapped), for: .touchUpInside)

        view.addSubview(allButton)
        allButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            allButton.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
            allButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            allButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    // MARK: - Actions

    @objc private func allButtonTapped() {
        openInfiniteGrid(for: nil)  // nil means all exercises
    }

    private func openInfiniteGrid(for muscle: Muscle?) {
        let infiniteGridVC = InfiniteExerciseGridViewController(muscle: muscle)
        navigationController?.pushViewController(infiniteGridVC, animated: true)
    }
}
