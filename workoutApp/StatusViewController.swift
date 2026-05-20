//
//  StatusViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 20/05/2026.
//  Copyright © 2026 Alexander Kvamme. All rights reserved.
//

import UIKit
import MuscleMap
import SnapKit

// Alias to disambiguate from the app's Core Data Muscle entity
private typealias MMuscle = MuscleMap.Muscle

class StatusViewController: SelectionViewController {

    private var muscleMapView: MuscleMapView!

    // All muscles shown on the body map — untrained ones are highlighted dark by default
    private static let allTrackedMuscles: [MMuscle] = [
        .biceps, .triceps, .gluteal, .abs, .chest, .deltoids,
        .upperBack, .lowerBack, .trapezius, .quadriceps, .hamstring, .calves, .forearm
    ]

    init() {
        super.init(header: AnimatedScreenHeader(header: "Status", subheader: "of your body"))
    }

    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        setupMuscleMap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        globalTabBar.showIt()
        header.play()
        updateMuscleColors()
    }

    // MARK: - Setup

    private func setupMuscleMap() {
        // Light base so gray highlights are clearly visible against the body
        let style = BodyViewStyle(
            defaultFillColor: .init(white: 0.93, opacity: 1),
            headColor: .init(white: 0.88, opacity: 1),
            hairColor: .init(white: 0.55, opacity: 1)
        )
        muscleMapView = MuscleMapView(gender: .male, side: .front, style: style)
        view.addSubview(muscleMapView)
        muscleMapView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(muscleMapView.snp.width).multipliedBy(1.5)
        }
    }

    // MARK: - Muscle coloring

    private func updateMuscleColors() {
        let t1 = UserDefaultsFacade.muscleThreshold(for: DefaultKeys.muscleLightGray, fallback: 1)
        let t2 = UserDefaultsFacade.muscleThreshold(for: DefaultKeys.muscleGray,      fallback: 10)
        let t3 = UserDefaultsFacade.muscleThreshold(for: DefaultKeys.muscleDarkGray,  fallback: 25)
        let t4 = UserDefaultsFacade.muscleThreshold(for: DefaultKeys.muscleBlack,     fallback: 50)

        muscleMapView.clearHighlights()

        // Build counts per MMuscle: try stored musclesUsed first, fall back to name-based mapping
        var countPerMuscle: [MMuscle: Int] = [:]
        for log in DatabaseFacade.fetchAllWorkoutLogs() {
            guard let exerciseLogs = log.loggedExercises?.array as? [ExerciseLog] else { continue }
            for exerciseLog in exerciseLogs {
                guard let exercise = exerciseLog.exerciseDesign else { continue }
                let storedMuscles = (exercise.musclesUsed as? Set<Muscle>)?.compactMap { mmMuscles(for: $0.getName()) }.flatMap { $0 } ?? []
                let resolved: [MMuscle]
                if storedMuscles.isEmpty {
                    resolved = mmMusclesForExercise(named: exercise.name ?? "")
                } else {
                    resolved = storedMuscles
                }
                for muscle in resolved {
                    countPerMuscle[muscle, default: 0] += 1
                }
            }
        }

        // Apply to all muscles: untrained = black, well-trained = near-white
        for muscle in StatusViewController.allTrackedMuscles {
            let count = countPerMuscle[muscle, default: 0]
            let color = muscleColor(count: count, t1: t1, t2: t2, t3: t3, t4: t4)
            muscleMapView.highlight(muscle, color: color)
        }
    }

    private func muscleColor(count: Int, t1: Int, t2: Int, t3: Int, t4: Int) -> UIColor {
        if count >= t4 { return UIColor(white: 0.88, alpha: 1.0) } // very trained — blends with body
        if count >= t3 { return UIColor(white: 0.72, alpha: 1.0) }
        if count >= t2 { return UIColor(white: 0.50, alpha: 1.0) }
        if count >= t1 { return UIColor(white: 0.28, alpha: 1.0) }
        return .black // never trained — most visible
    }

    /// Maps the app's muscle names (Core Data) to MuscleMap enum values.
    private func mmMuscles(for name: String) -> [MMuscle] {
        switch name.uppercased() {
        case "BICEPS":              return [.biceps]
        case "TRICEPS":             return [.triceps]
        case "GLUTES", "GLUTE":     return [.gluteal]
        case "CORE", "ABS":         return [.abs]
        case "CHEST":               return [.chest]
        case "SHOULDERS", "DELTS":  return [.deltoids]
        case "BACK":                return [.upperBack, .lowerBack, .trapezius]
        case "QUADS", "QUAD":       return [.quadriceps]
        case "LEGS", "LEG":         return [.quadriceps, .hamstring, .gluteal, .calves]
        case "HAMSTRING", "HAMSTRINGS": return [.hamstring]
        case "CALVES", "CALF":      return [.calves]
        case "FOREARM", "FOREARMS": return [.forearm]
        case "LATS", "LAT":         return [.upperBack, .lowerBack]
        case "TRAPS", "TRAP":       return [.trapezius]
        default:
            print("🏋️ [Status] unmapped muscle name: '\(name)'")
            return []
        }
    }

    /// Fallback mapping for manually-created exercises that have no stored musclesUsed.
    private func mmMusclesForExercise(named name: String) -> [MMuscle] {
        switch name.uppercased() {
        // Legs
        case "PISTOL SQUATS", "PISTOL SQUAT":
            return [.quadriceps, .gluteal, .abs, .calves]
        case "BOX STEPS", "BOX STEP":
            return [.quadriceps, .gluteal, .calves]
        case "BOX JUMP", "BOX JUMPS":
            return [.quadriceps, .gluteal, .calves, .abs]
        case "LUNGES", "LUNGE":
            return [.quadriceps, .gluteal, .hamstring]
        case "EXTREME JUMP", "EXTREME JUMPS":
            return [.quadriceps, .gluteal, .calves, .abs]
        // Push
        case "PUSH UP", "PUSH UPS", "PUSHUP", "PUSHUPS":
            return [.chest, .deltoids, .triceps]
        case "INCLINED PUSH UP", "INCLINED PUSH UPS":
            return [.chest, .deltoids, .triceps]
        case "ARCHER PUSH UP", "ARCHER PUSH UPS":
            return [.chest, .deltoids, .triceps]
        case "PARTIAL 1H PUSH UP", "FULL 1H PUSH UP", "PARTIAL 1H PUSH UPS", "FULL 1H PUSH UPS":
            return [.chest, .deltoids, .triceps, .abs]
        case "PIKE PUSHUPS", "PIKE PUSH UP", "PIKE PUSH UPS":
            return [.deltoids, .triceps, .abs]
        case "HANDSTAND PUSH-UP", "HANDSTAND PUSH UP", "HANDSTAND PUSH UPS":
            return [.deltoids, .triceps, .abs]
        case "STRAIGHT BAR DIPS", "BAR DIPS", "DIPS":
            return [.triceps, .chest, .deltoids]
        // Handstand
        case "HANDSTAND HOLDS", "HANDSTAND HOLD":
            return [.deltoids, .abs, .triceps]
        case "WALL HANDSTAND", "WALL HANDSTANDS":
            return [.deltoids, .abs, .triceps]
        // Pull
        case "EXPLOSIVE PULL UPS", "EXPLOSIVE PULL UP":
            return [.upperBack, .biceps]
        case "NEGATIVE MUSCLE UP", "NEGATIVE MUSCLE UPS":
            return [.upperBack, .lowerBack, .biceps, .chest, .deltoids]
        case "BANDED MUSCLE UP", "BANDED MUSCLE UPS":
            return [.upperBack, .lowerBack, .biceps, .chest, .deltoids]
        case "UPSIDE DOWN ROWS", "UPSIDE DOWN ROW":
            return [.upperBack, .biceps]
        case "TRANSITION PRACTICE":
            return [.upperBack, .deltoids, .chest, .abs]
        // Core
        case "DRAGON FLAGS", "DRAGON FLAG":
            return [.abs, .upperBack, .lowerBack]
        case "TOES TO BAR":
            return [.abs, .upperBack]
        case "TRUNK SLAMMERS", "TRUNK SLAMMER":
            return [.abs, .upperBack, .lowerBack]
        case "BAR POUNDERS", "BAR POUNDER":
            return [.abs, .upperBack, .deltoids]
        case "DRAG FLAG", "DRAG FLAGS":
            return [.abs, .upperBack, .deltoids]
        // Other
        case "HAND STRENGTHENERS", "HAND STRENGTHENER":
            return [.forearm]
        case "WARM UP", "WARMUP":
            return [.deltoids, .abs]
        default:
            return []
        }
    }
}
