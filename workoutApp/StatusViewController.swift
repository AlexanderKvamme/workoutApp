//
//  StatusViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 20/05/2026.
//  Copyright © 2026 Alexander Kvamme. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData
import MuscleMap
import SnapKit

private typealias MMuscle = MuscleMap.Muscle

private let frontMuscles: Set<MMuscle> = [.deltoids, .chest, .biceps, .forearm, .abs, .obliques, .quadriceps, .adductors, .tibialis, .calves, .trapezius, .triceps]
private let backMuscles:  Set<MMuscle> = [.trapezius, .triceps, .upperBack, .lowerBack, .gluteal, .hamstring, .adductors, .calves, .deltoids, .forearm]

private struct MuscleGroupOption {
    let id: String
    let title: String
    let detail: String
    let absorbed: Set<MMuscle>
    let representative: MMuscle
    let groupedLabel: String?   // button label override when the group is active
}

private let muscleGroupOptions: [MuscleGroupOption] = [
    MuscleGroupOption(
        id: "group_thighs",
        title: "Group Thighs",
        detail: "Quads, hamstrings & adductors combined as one group",
        absorbed: [.hamstring, .adductors],
        representative: .quadriceps,
        groupedLabel: "Thighs"
    ),
    MuscleGroupOption(
        id: "group_back",
        title: "Group Back",
        detail: "Upper back, lower back & traps combined as one group",
        absorbed: [.lowerBack, .trapezius],
        representative: .upperBack,
        groupedLabel: "Back"
    ),
    MuscleGroupOption(
        id: "group_lower_legs",
        title: "Group Lower Legs",
        detail: "Tibialis redirects to Calves",
        absorbed: [.tibialis],
        representative: .calves,
        groupedLabel: nil
    ),
]

private let kEnabledGroupsKey = "bodyScreen.enabledMuscleGroups"

class StatusViewController: SelectionViewController {

    private var muscleMapView: MuscleMapView!
    private var startImprovButton: UIButton!
    private var selectedMMuscles: Set<MMuscle> = []
    private var currentSide: BodySide = .front
    private var muscleCountCache: [MMuscle: Int] = [:]
    private let subtitleLabel = UILabel()
    private let muscleListStack = UIStackView()
    private var muscleListButtons: [(MMuscle, UIButton)] = []

    private var enabledGroupIDs: Set<String> {
        get {
            let allIDs = Set(muscleGroupOptions.map(\.id))
            guard let stored = UserDefaults.standard.stringArray(forKey: kEnabledGroupsKey) else {
                return allIDs
            }
            var result = Set(stored)
            // Auto-enable any group IDs added since the user last opened settings
            let newIDs = allIDs.subtracting(result)
            if !newIDs.isEmpty {
                result.formUnion(newIDs)
                UserDefaults.standard.set(Array(result), forKey: kEnabledGroupsKey)
            }
            return result
        }
        set { UserDefaults.standard.set(Array(newValue), forKey: kEnabledGroupsKey) }
    }

    // Top-to-bottom, front-to-back ordering.
    private let muscleListData: [(MMuscle, String)] = [
        (.deltoids,   "Shoulders"),
        (.chest,      "Chest"),
        (.biceps,     "Biceps"),
        (.forearm,    "Forearms"),
        (.abs,        "Abs"),
        (.obliques,   "Obliques"),
        (.quadriceps, "Quads"),
        (.hamstring,  "Hamstrings"),
        (.adductors,  "Adductors"),
        (.tibialis,   "Tibialis"),
        (.calves,     "Calves"),
        (.triceps,    "Triceps"),
        (.trapezius,  "Traps"),
        (.upperBack,  "Upper back"),
        (.lowerBack,  "Lower back"),
        (.gluteal,    "Glutes"),
    ]

    private static let allTrackedMuscles: [MMuscle] = [
        .biceps, .triceps, .gluteal, .abs, .obliques, .chest, .deltoids,
        .upperBack, .lowerBack, .trapezius, .quadriceps, .hamstring, .adductors, .calves, .forearm,
        .tibialis
    ]

    init() {
        super.init(header: AnimatedScreenHeader(header: "Body", subheader: "today"))
    }

    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        repositionHeader()
        setupSubtitleLabel()
        setupMuscleMap()
        setupMuscleList()
        setupBottomButtons()
        setupGearButton()
        setupInfoButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        globalTabBar.showIt()
        header.play()
        updateMuscleColors()
    }

    // MARK: - Setup

    private func repositionHeader() {
        // Removing and re-adding the header clears all constraints the parent applied,
        // letting us place it where we want without fighting priority conflicts.
        header.removeFromSuperview()
        view.addSubview(header)
        header.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.centerX.equalToSuperview()
        }
    }

    private func setupSubtitleLabel() {
        subtitleLabel.text = "Pick the body parts you want to train"
        subtitleLabel.font = h3
        subtitleLabel.textColor = UIColor(white: 0.6, alpha: 1)
        subtitleLabel.textAlignment = .center
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.7
        view.addSubview(subtitleLabel)
        // Independent of body map — breaks the constraint chain that caused the
        // muscle list's minimum height to push this label downward.
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(195)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    private func setupMuscleMap() {
        muscleMapView = MuscleMapView(gender: .male, side: .front, style: bodyStyle())
        view.addSubview(muscleMapView)
        muscleMapView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(230)
            make.bottom.equalToSuperview().offset(-130)
            make.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.55)
        }

        muscleMapView.onMuscleSelected = { [weak self] muscle, _ in
            guard let self, let resolved = self.resolveForSelection(muscle) else { return }
            if self.selectedMMuscles.contains(resolved) {
                self.selectedMMuscles.remove(resolved)
            } else {
                self.selectedMMuscles.insert(resolved)
            }
            self.syncMapSelection()
            self.updateAutoButton()
            self.updateMuscleListButtonStates()
        }

        let swipeLeft  = UISwipeGestureRecognizer(target: self, action: #selector(flipTapped))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(flipTapped))
        swipeRight.direction = .right
        muscleMapView.addGestureRecognizer(swipeLeft)
        muscleMapView.addGestureRecognizer(swipeRight)
    }

    private func setupBottomButtons() {
        // WellRoundedTabBarController doesn't update child safe-area insets for its own bar,
        // so anchor to view.bottom and leave enough room for the custom tab bar (~83 pt).
        let bottomInset = -150

        let flipButton = makeButton(title: "flip")
        flipButton.addTarget(self, action: #selector(flipTapped), for: .touchUpInside)
        view.addSubview(flipButton)
        flipButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(bottomInset)
        }

        startImprovButton = makeButton(title: "auto")
        startImprovButton.addTarget(self, action: #selector(startImprovTapped), for: .touchUpInside)
        view.addSubview(startImprovButton)
        startImprovButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(bottomInset)
        }
    }

    private func setupMuscleList() {
        muscleListStack.axis = .vertical
        muscleListStack.spacing = 10
        muscleListStack.alignment = .fill
        muscleListStack.distribution = .fill
        view.addSubview(muscleListStack)
        muscleListStack.snp.makeConstraints { make in
            make.leading.equalTo(muscleMapView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(muscleMapView.snp.centerY)
        }

        for (index, (muscle, name)) in muscleListData.enumerated() {
            let button = makeMuscleListButton(title: name)
            button.tag = index
            button.addTarget(self, action: #selector(muscleListButtonTapped(_:)), for: .touchUpInside)
            muscleListStack.addArrangedSubview(button)
            muscleListButtons.append((muscle, button))
        }

        updateMuscleListVisibility()
    }

    private func setupGearButton() {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        btn.setImage(UIImage(systemName: "gearshape", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor(white: 0.55, alpha: 1)
        btn.addTarget(self, action: #selector(showSettings), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.trailing.equalToSuperview().offset(-20)
        }
    }

    private func setupInfoButton() {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        btn.setImage(UIImage(systemName: "questionmark.circle", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor(white: 0.55, alpha: 1)
        btn.addTarget(self, action: #selector(showInfo), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(20)
        }
    }

    // MARK: - Muscle resolution

    /// Returns nil for cosmetic/irrelevant taps (head, neck); remaps structural non-workout
    /// muscles (knees, feet, hands) and applies user-configured groupings.
    private func resolveForSelection(_ muscle: MMuscle) -> MMuscle? {
        let structural = remapStructural(muscle)
        guard let m = structural else { return nil }
        return applyGroupings(m)
    }

    private func remapStructural(_ muscle: MMuscle) -> MMuscle? {
        switch muscle {
        case .head, .neck:   return nil
        case .knees:         return .quadriceps
        case .feet, .ankles: return .calves
        case .hands:         return .forearm
        default:             return muscle
        }
    }

    private func applyGroupings(_ muscle: MMuscle) -> MMuscle {
        for option in muscleGroupOptions where enabledGroupIDs.contains(option.id) {
            if option.absorbed.contains(muscle) { return option.representative }
        }
        return muscle
    }

    private func absorbedMuscles() -> Set<MMuscle> {
        muscleGroupOptions
            .filter { enabledGroupIDs.contains($0.id) }
            .reduce(into: Set<MMuscle>()) { $0.formUnion($1.absorbed) }
    }

    /// Expands the logical selection so the full body shape lights up on the map.
    /// Representatives expand to include absorbed muscles when a group is active.
    private func expandedForMap(_ muscles: Set<MMuscle>) -> Set<MMuscle> {
        var out = muscles
        // Expand active group representatives to cover their absorbed muscles on the map
        for option in muscleGroupOptions where enabledGroupIDs.contains(option.id) {
            if out.contains(option.representative) { out.formUnion(option.absorbed) }
        }
        // Structural companions (non-selectable shapes that complete the body outline)
        if out.contains(.calves)                               { out.formUnion([.feet, .ankles, .tibialis]) }
        if out.contains(.quadriceps)                           { out.insert(.knees) }
        if out.contains(.obliques)                             { out.insert(.serratus) }
        if out.contains(.forearm)                               { out.insert(.hands) }
        return out
    }

    private func syncMapSelection() {
        muscleMapView.selectedMuscles = expandedForMap(selectedMMuscles)
    }

    // MARK: - Button factories

    private func makeButton(title: String) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 4, trailing: 16)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = h3.withSize(18)
            return outgoing
        }
        return UIButton(configuration: config)
    }

    // Identical style to makeButton but with a muted gray palette
    private func makeMuscleListButton(title: String) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = UIColor(white: 0.87, alpha: 1)
        config.baseForegroundColor = UIColor(white: 0.42, alpha: 1)
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 4, trailing: 16)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = h3.withSize(18)
            return outgoing
        }
        return UIButton(configuration: config)
    }

    private func bodyStyle() -> BodyViewStyle {
        BodyViewStyle(
            defaultFillColor: .init(white: 0.93, opacity: 1),
            headColor: .init(white: 0.88, opacity: 1),
            hairColor: .init(white: 0.55, opacity: 1)
        )
    }

    // MARK: - Actions

    @objc private func muscleListButtonTapped(_ sender: UIButton) {
        let muscle = muscleListData[sender.tag].0
        if selectedMMuscles.contains(muscle) {
            selectedMMuscles.remove(muscle)
        } else {
            selectedMMuscles.insert(muscle)
        }
        syncMapSelection()
        updateAutoButton()
        updateMuscleListButtonStates()
    }

    @objc private func showSettings() {
        let opts = muscleGroupOptions.map {
            BodySettingsView.GroupOption(id: $0.id, title: $0.title, detail: $0.detail)
        }
        let settingsView = BodySettingsView(
            options: opts,
            enabledGroupIDs: enabledGroupIDs,
            onGroupsChanged: { [weak self] newIDs in
                guard let self else { return }
                self.enabledGroupIDs = newIDs
                self.updateMuscleListVisibility()
            },
            onThresholdChanged: { [weak self] in
                self?.updateMuscleColors()
            }
        )
        let hostingVC = UIHostingController(rootView: settingsView)
        if #available(iOS 16, *), let sheet = hostingVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(hostingVC, animated: true)
    }

    @objc private func showInfo() {
        let infoView = ColorLegendView(
            freshDays:   dayThreshold(Self.kFreshDays,   fallback: 2),
            staleDays:   dayThreshold(Self.kStaleDays,   fallback: 5),
            fadeDays:    dayThreshold(Self.kFadeDays,    fallback: 10),
            warningDays: dayThreshold(Self.kWarningDays, fallback: 14)
        )
        let hostingVC = UIHostingController(rootView: infoView)
        if let sheet = hostingVC.sheetPresentationController {
            if #available(iOS 16, *) {
                sheet.detents = [.custom { _ in 320 }, .large()]
            } else {
                sheet.detents = [.large()]
            }
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        present(hostingVC, animated: true)
    }

    @objc private func flipTapped() {
        currentSide = currentSide == .front ? .back : .front
        muscleMapView.side = currentSide
        updateMuscleListVisibility()
    }

    @objc private func startImprovTapped() {
        if selectedMMuscles.isEmpty {
            let randomMuscle = StatusViewController.allTrackedMuscles.randomElement()!
            selectedMMuscles.insert(randomMuscle)
            syncMapSelection()
            updateMuscleListButtonStates()
            updateAutoButton()
            return
        }

        let label = Array(selectedMMuscles).prefix(2).map { $0.displayName }.joined(separator: " + ")
        let picker = SetCountPickerController(title: label) { [weak self] setCount in
            guard let self else { return }
            let exercises = self.exercisesForSelectedMuscles()
            guard !exercises.isEmpty else {
                globalTabBar.showIt()
                return
            }
            let vc = ImprovWorkoutController(exercises: exercises, title: label)
            vc.setCount = setCount
            self.navigationController?.pushViewController(vc, animated: true)
        }
        present(picker, animated: true)
    }

    // MARK: - State updates

    private func updateAutoButton() {
        let hasSelection = !selectedMMuscles.isEmpty
        var config = startImprovButton.configuration
        config?.title = hasSelection ? "start" : "auto"
        startImprovButton.configuration = config
    }

    private func updateMuscleListButtonStates() {
        for (muscle, button) in muscleListButtons {
            let isSelected = selectedMMuscles.contains(muscle)
            var config = button.configuration
            config?.baseBackgroundColor = isSelected ? .black : UIColor(white: 0.87, alpha: 1)
            config?.baseForegroundColor = isSelected ? .white : UIColor(white: 0.42, alpha: 1)
            button.configuration = config
        }
    }

    private func updateMuscleListVisibility() {
        let visibleSet = currentSide == .front ? frontMuscles : backMuscles
        let absorbed = absorbedMuscles()

        // When a group is active, show the representative on whichever side(s) its absorbed
        // muscles would normally appear — e.g. "Back" button shows on the back view.
        var crossSideVisible = Set<MMuscle>()
        for option in muscleGroupOptions where enabledGroupIDs.contains(option.id) {
            if !option.absorbed.isDisjoint(with: visibleSet) {
                crossSideVisible.insert(option.representative)
            }
        }

        for (muscle, button) in muscleListButtons {
            let visible = visibleSet.contains(muscle) || crossSideVisible.contains(muscle)
            button.isHidden = !visible || absorbed.contains(muscle)
        }
        updateGroupedLabels()
    }

    private func updateGroupedLabels() {
        for option in muscleGroupOptions {
            guard let label = option.groupedLabel,
                  let (_, button) = muscleListButtons.first(where: { $0.0 == option.representative })
            else { continue }
            let isActive = enabledGroupIDs.contains(option.id)
            let defaultLabel = muscleListData.first(where: { $0.0 == option.representative })?.1 ?? ""
            var config = button.configuration
            config?.title = isActive ? label : defaultLabel
            button.configuration = config
        }
    }

    // MARK: - Exercise fetching

    private func exercisesForSelectedMuscles() -> [Exercise] {
        var seen = Set<NSManagedObjectID>()
        var result: [Exercise] = []

        for mmMuscle in selectedMMuscles {
            guard let name = cdMuscleName(for: mmMuscle),
                  let cdMuscle = DatabaseFacade.getMuscle(named: name) else { continue }
            let exercises = DatabaseFacade.fetchExercises(containing: cdMuscle) ?? []
            for ex in exercises {
                if seen.insert(ex.objectID).inserted {
                    result.append(ex)
                }
            }
        }
        return result
    }

    private func cdMuscleName(for muscle: MMuscle) -> String? {
        switch muscle {
        case .biceps:                                       return "BICEPS"
        case .triceps:                                      return "TRICEPS"
        case .gluteal:                                      return "GLUTES"
        case .abs, .obliques:                              return "CORE"
        case .chest:                                        return "CHEST"
        case .deltoids:                                     return "SHOULDERS"
        case .upperBack, .lowerBack, .trapezius: return "BACK"
        case .quadriceps, .hamstring, .adductors, .calves, .tibialis:  return "LEGS"
        default:                                            return nil
        }
    }

    // MARK: - Muscle coloring

    // UserDefaults keys for day-based thresholds
    static let kFreshDays   = "muscleDays.fresh"    // ≤ this → black (worked out recently)
    static let kStaleDays   = "muscleDays.stale"    // ≤ this → dark gray
    static let kFadeDays    = "muscleDays.fade"     // ≤ this → medium gray
    static let kWarningDays = "muscleDays.warning"  // > this → red (muscle loss risk)

    private func dayThreshold(_ key: String, fallback: Int) -> Int {
        let v = UserDefaults.standard.integer(forKey: key)
        return v > 0 ? v : fallback
    }

    private func updateMuscleColors() {
        let freshDays   = dayThreshold(Self.kFreshDays,   fallback: 2)
        let staleDays   = dayThreshold(Self.kStaleDays,   fallback: 5)
        let fadeDays    = dayThreshold(Self.kFadeDays,    fallback: 10)
        let warningDays = dayThreshold(Self.kWarningDays, fallback: 14)

        muscleMapView.clearHighlights()

        // Build "days since last workout" per muscle
        var lastDate: [MMuscle: Date] = [:]
        let sortedLogs = DatabaseFacade.fetchAllWorkoutLogs()
            .sorted { ($0.dateStarted as Date? ?? .distantPast) > ($1.dateStarted as Date? ?? .distantPast) }

        for log in sortedLogs {
            guard let logDate = log.dateStarted as Date?,
                  let exerciseLogs = log.loggedExercises?.array as? [ExerciseLog] else { continue }
            for exerciseLog in exerciseLogs {
                guard let exercise = exerciseLog.exerciseDesign else { continue }
                let storedMuscles = (exercise.musclesUsed as? Set<Muscle>)?
                    .compactMap { mmMuscles(for: $0.getName()) }.flatMap { $0 } ?? []
                let resolved: [MMuscle] = storedMuscles.isEmpty
                    ? mmMusclesForExercise(named: exercise.name ?? "")
                    : storedMuscles
                for muscle in resolved where lastDate[muscle] == nil {
                    lastDate[muscle] = logDate
                }
            }
        }

        let now = Date()
        var colorMap: [MMuscle: UIColor] = [:]
        for muscle in StatusViewController.allTrackedMuscles {
            guard let date = lastDate[muscle] else { continue }
            let days = Int(now.timeIntervalSince(date) / 86400)
            let color = muscleColor(days: days, fresh: freshDays, stale: staleDays, fade: fadeDays, warning: warningDays)
            muscleMapView.highlight(muscle, color: color)
            colorMap[muscle] = color
        }

        // Propagate color to structural companion muscles so the full body fills in
        let companions: [(MMuscle, [MMuscle])] = [
            (.calves,     [.feet, .ankles, .tibialis]),
            (.quadriceps, [.knees]),
            (.obliques,   [.serratus]),
        ]
        for (source, targets) in companions {
            guard let color = colorMap[source] else { continue }
            for target in targets {
                muscleMapView.highlight(target, color: color)
                colorMap[target] = color
            }
        }

        // Hands are a visual extension of forearms — always use exactly the same color.
        // If forearms have no workout history, hands stay at the default body fill.
        if let forearmColor = colorMap[.forearm] {
            muscleMapView.highlight(.hands, color: forearmColor)
            colorMap[.hands] = forearmColor
        }
        // Head/face: always use the default body fill (untrained appearance)
        muscleMapView.highlight(.head, color: UIColor(white: 0.93, alpha: 1))

        syncMapSelection()
    }

    private func muscleColor(days: Int, fresh: Int, stale: Int, fade: Int, warning: Int) -> UIColor {
        if days <= fresh  { return .black }
        if days <= stale  { return UIColor(white: 0.22, alpha: 1.0) }
        if days <= fade   { return UIColor(white: 0.50, alpha: 1.0) }
        if days <= warning { return UIColor(white: 0.75, alpha: 1.0) }
        return UIColor(red: 0.75, green: 0.18, blue: 0.18, alpha: 1.0) // red = losing muscle
    }

    private func mmMuscles(for name: String) -> [MMuscle] {
        switch name.uppercased() {
        case "BICEPS":                  return [.biceps]
        case "TRICEPS":                 return [.triceps]
        case "GLUTES", "GLUTE":        return [.gluteal]
        case "CORE", "ABS":            return [.abs, .obliques]
        case "CHEST":                   return [.chest]
        case "SHOULDERS", "DELTS":     return [.deltoids]
        case "BACK":                    return [.upperBack, .lowerBack, .trapezius]
        case "QUADS", "QUAD":          return [.quadriceps]
        case "LEGS", "LEG":            return [.quadriceps, .hamstring, .adductors, .gluteal, .calves, .tibialis]
        case "HAMSTRING", "HAMSTRINGS": return [.hamstring]
        case "ADDUCTORS", "ADDUCTOR":  return [.adductors]
        case "CALVES", "CALF":         return [.calves]
        case "FOREARM", "FOREARMS":    return [.forearm]
        case "LATS", "LAT":            return [.upperBack, .lowerBack]
        case "TRAPS", "TRAP":          return [.trapezius]
        default:                        return []
        }
    }

    private func mmMusclesForExercise(named name: String) -> [MMuscle] {
        switch name.uppercased() {
        case "PISTOL SQUATS", "PISTOL SQUAT":                    return [.quadriceps, .gluteal, .abs, .calves]
        case "BOX STEPS", "BOX STEP":                            return [.quadriceps, .gluteal, .calves]
        case "BOX JUMP", "BOX JUMPS":                            return [.quadriceps, .gluteal, .calves, .abs]
        case "LUNGES", "LUNGE":                                  return [.quadriceps, .gluteal, .hamstring, .adductors]
        case "EXTREME JUMP", "EXTREME JUMPS":                    return [.quadriceps, .gluteal, .calves, .abs]
        case "PUSH UP", "PUSH UPS", "PUSHUP", "PUSHUPS":        return [.chest, .deltoids, .triceps]
        case "INCLINED PUSH UP", "INCLINED PUSH UPS":           return [.chest, .deltoids, .triceps]
        case "ARCHER PUSH UP", "ARCHER PUSH UPS":               return [.chest, .deltoids, .triceps]
        case "PARTIAL 1H PUSH UP", "FULL 1H PUSH UP",
             "PARTIAL 1H PUSH UPS", "FULL 1H PUSH UPS":        return [.chest, .deltoids, .triceps, .abs]
        case "PIKE PUSHUPS", "PIKE PUSH UP", "PIKE PUSH UPS":   return [.deltoids, .triceps, .abs]
        case "HANDSTAND PUSH-UP", "HANDSTAND PUSH UP",
             "HANDSTAND PUSH UPS":                               return [.deltoids, .triceps, .abs]
        case "STRAIGHT BAR DIPS", "BAR DIPS", "DIPS":          return [.triceps, .chest, .deltoids]
        case "HANDSTAND HOLDS", "HANDSTAND HOLD":               return [.deltoids, .abs, .triceps]
        case "WALL HANDSTAND", "WALL HANDSTANDS":               return [.deltoids, .abs, .triceps]
        case "EXPLOSIVE PULL UPS", "EXPLOSIVE PULL UP":         return [.upperBack, .biceps]
        case "NEGATIVE MUSCLE UP", "NEGATIVE MUSCLE UPS",
             "BANDED MUSCLE UP", "BANDED MUSCLE UPS":          return [.upperBack, .lowerBack, .biceps, .chest, .deltoids]
        case "UPSIDE DOWN ROWS", "UPSIDE DOWN ROW":             return [.upperBack, .biceps]
        case "TRANSITION PRACTICE":                              return [.upperBack, .deltoids, .chest, .abs]
        case "DRAGON FLAGS", "DRAGON FLAG":                     return [.abs, .upperBack, .lowerBack]
        case "TOES TO BAR":                                      return [.abs, .upperBack]
        case "TRUNK SLAMMERS", "TRUNK SLAMMER":                 return [.abs, .upperBack, .lowerBack]
        case "BAR POUNDERS", "BAR POUNDER":                     return [.abs, .upperBack, .deltoids]
        case "DRAG FLAG", "DRAG FLAGS":                          return [.abs, .upperBack, .deltoids]
        case "HAND STRENGTHENERS", "HAND STRENGTHENER":         return [.forearm]
        case "WARM UP", "WARMUP":                               return [.deltoids, .abs]
        default:                                                  return []
        }
    }
}

// MARK: - Color Legend Sheet

private struct ColorLegendView: View {
    let freshDays: Int
    let staleDays: Int
    let fadeDays: Int
    let warningDays: Int

    private struct LegendRow: Identifiable {
        let id = UUID()
        let color: Color
        let label: String
        let detail: String
    }

    private var rows: [LegendRow] {
        [
            LegendRow(color: .black,
                      label: "Fresh",
                      detail: "Worked out within \(freshDays) day\(freshDays == 1 ? "" : "s")"),
            LegendRow(color: Color(white: 0.22),
                      label: "Stale",
                      detail: "\(freshDays + 1)–\(staleDays) days since last session"),
            LegendRow(color: Color(white: 0.50),
                      label: "Fading",
                      detail: "\(staleDays + 1)–\(fadeDays) days since last session"),
            LegendRow(color: Color(white: 0.75),
                      label: "Dormant",
                      detail: "\(fadeDays + 1)–\(warningDays) days since last session"),
            LegendRow(color: Color(red: 0.75, green: 0.18, blue: 0.18),
                      label: "Warning",
                      detail: "Over \(warningDays) days — risk of muscle loss"),
        ]
    }

    private let appBg  = Color(UIColor.systemGroupedBackground)
    private let rowBg  = Color(UIColor.secondarySystemGroupedBackground)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Each muscle is colored by how long ago you last trained it. The thresholds are adjustable in Settings.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 20)

                    VStack(spacing: 1) {
                        ForEach(rows) { row in
                            HStack(spacing: 14) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(row.color)
                                    .frame(width: 36, height: 36)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(row.label)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Text(row.detail)
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(rowBg)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)

                    Text("Untrained muscles use the body's default fill color.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                }
            }
            .background(appBg.ignoresSafeArea())
            .navigationTitle("How It Works")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
