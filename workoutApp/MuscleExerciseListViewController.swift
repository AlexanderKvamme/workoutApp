//
//  MuscleExerciseListViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 24/05/2026.
//  Copyright © 2026 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT
import SnapKit

class MuscleExerciseListViewController: UIViewController {

    // MARK: - Properties

    private let muscleName: String
    private var exercises: [Exercise]

    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Init

    init(muscleName: String, exercises: [Exercise]) {
        self.muscleName = muscleName
        self.exercises = exercises
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.akLight
        setupHeader()
    }

    // MARK: - Setup

    private func setupHeader() {
        let label = UILabel()
        label.text = muscleName.uppercased()
        label.font = AKFont.round(.black, 28)
        label.textColor = UIColor.akDark
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        let countLabel = UILabel()
        countLabel.text = "\(exercises.count) exercise\(exercises.count == 1 ? "" : "s")"
        countLabel.font = AKFont.round(.medium, 15)
        countLabel.textColor = UIColor(white: 0.55, alpha: 1)
        countLabel.textAlignment = .center
        view.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        let divider = UIView()
        divider.backgroundColor = UIColor(white: 0.88, alpha: 1)
        view.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(1)
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Long press

    private func showExerciseDetail(for exercise: Exercise, at indexPath: IndexPath) {
        let name = exercise.name?.capitalized ?? "Exercise"
        let muscles = (exercise.musclesUsed as? Set<Muscle>)?
            .map { $0.getName().capitalized }
            .sorted()
            .joined(separator: ", ")
        let muscleText = muscles.map { $0.isEmpty ? "No muscles assigned" : $0 } ?? "No muscles assigned"

        let sheet = UIAlertController(title: name, message: muscleText, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Delete Exercise", style: .destructive) { [weak self] _ in
            self?.deleteExercise(exercise, at: indexPath)
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    private func deleteExercise(_ exercise: Exercise, at indexPath: IndexPath) {
        DatabaseFacade.delete(exercise)
        DatabaseFacade.saveContext()
        exercises.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UITableViewDataSource

extension MuscleExerciseListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        exercises.isEmpty ? 1 : exercises.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        if exercises.isEmpty {
            var config = cell.defaultContentConfiguration()
            config.text = "No exercises yet"
            config.textProperties.font = AKFont.round(.medium, 17)
            config.textProperties.color = UIColor(white: 0.65, alpha: 1)
            config.textProperties.alignment = .center
            cell.contentConfiguration = config
        } else {
            var config = cell.defaultContentConfiguration()
            config.text = exercises[indexPath.row].name?.capitalized
            config.textProperties.font = AKFont.round(.bold, 18)
            config.textProperties.color = UIColor.akDark
            config.secondaryTextProperties.font = AKFont.round(.medium, 14)
            cell.contentConfiguration = config

            let lp = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            lp.minimumPressDuration = 0.4
            cell.addGestureRecognizer(lp)

            let separator = UIView()
            separator.backgroundColor = UIColor(white: 0.9, alpha: 1)
            cell.addSubview(separator)
            separator.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(24)
                make.height.equalTo(1)
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MuscleExerciseListViewController: UITableViewDelegate {

    @objc private func handleLongPress(_ gr: UILongPressGestureRecognizer) {
        guard gr.state == .began,
              let cell = gr.view as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell),
              indexPath.row < exercises.count else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        showExerciseDetail(for: exercises[indexPath.row], at: indexPath)
    }
}
