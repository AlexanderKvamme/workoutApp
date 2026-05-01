import UIKit
import AKKIT
import CoreData

// MARK: - ImprovWorkoutController
class ImprovWorkoutController: UIViewController, TimerDelegate {
    
    private let completionSkill: Skill?
    private let workoutTitle: String
    private var honeycombGrid: HoneycombGridView<Exercise>?
    private var exercises: [Exercise] = []
    private var progressBar = DotProgressView()
    private let badgesScrollView = UIScrollView()
    private let badgesStackView = UIStackView()
    private var badgeButtonsByMuscleID: [NSManagedObjectID: UIButton] = [:]
    private weak var filtersButton: UIButton?
    private var hasShownFilterButtonShimmer = false
    private var selectedMuscleIDs = Set<NSManagedObjectID>()
    private var availableMuscles: [Muscle] = []
    private var badgesExpanded = false
    private var confettiView: ConfettiView!
    var timerView = TimerView()
    private weak var navExitView: UIView?
    private let navTimerViewTag = 91001
    private let navExitViewTag = 91002
    private var log: WorkoutLog!
    private var didStartEntryPopIn = false
    
    let testOptions = ["60 s", "90 s", "2 m", "3 m", "4 m", "5 m", "6 m", "7 m", "8 m", "9 m"]
    var timerTargetString = APP_IS_DEBUG ? "30 s" : "3 m"
    var timerTargetInt = APP_IS_DEBUG ? 30 : 180
    var setCount = 10

    init(skill: Skill) {
        self.completionSkill = skill
        self.workoutTitle = skill.name ?? "Exercise"
        super.init(nibName: nil, bundle: nil)
        configureWorkout(skills: [skill], exercises: skill.getExercises().map { $0 })
    }
    
    init(skills: [Skill]) {
        self.completionSkill = skills.first
        self.workoutTitle = "ALL"
        super.init(nibName: nil, bundle: nil)
        
        var seenExerciseIDs = Set<NSManagedObjectID>()
        let allExercises = skills.flatMap { $0.getExercises().map { $0 } }.filter { exercise in
            let objectID = exercise.objectID
            guard !seenExerciseIDs.contains(objectID) else { return false }
            seenExerciseIDs.insert(objectID)
            return true
        }
        configureWorkout(skills: skills, exercises: allExercises)
    }
    
    private func configureWorkout(skills: [Skill], exercises: [Exercise]) {
        self.timerView.delegate = self

        let wStyle = DatabaseFacade.getWorkoutStyle(named: "IMPROV") ?? DatabaseFacade.makeWorkoutStyle(named: "IMPROV")
        let workout = DatabaseFacade.makeWorkout(withName: "Improv",
                                   workoutStyle: wStyle,
                                   muscles: [],
                                   skills: skills,
                                   exercises: [])
        self.log = DatabaseFacade.makeWorkoutLog(ofDesign: workout)
        self.exercises = exercises
        title = workoutTitle
        
        let listButton = UIBarButtonItem(
            image: UIImage(systemName: "list.bullet")?.withRenderingMode(.alwaysOriginal).withTintColor(.black),
            style: .plain,
            target: self,
            action: #selector(showList)
        )

        self.navigationItem.rightBarButtonItem = listButton
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        
        // Initialize confetti view
        confettiView = ConfettiView(frame: view.bounds)
        confettiView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(confettiView)
        
        // Set up UI components
        setupTimerView()
        setupProgressBar()
        setupBadges()
        setupHoneycombGrid()
        setupNavigationOverlay()
        
        // Make sure navigation bar is visible
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationItem.hidesBackButton = true
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationOverlay()
        
        if progressBar.currentStep == progressBar.totalSteps {
            navigationController?.popViewController(animated: true)
            return
        }
        
        if !didStartEntryPopIn {
            didStartEntryPopIn = true
            view.layoutIfNeeded()
            honeycombGrid?.animateHexagonsPopIn(force: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startFilterButtonShimmer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // This ensures the honeycomb grid is laid out after the view's bounds are finalized
        honeycombGrid?.setNeedsLayout()
        confettiView.frame = view.bounds
        positionNavigationOverlay()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navExitView?.removeFromSuperview()
        navExitView = nil
        timerView.removeFromSuperview()
    }
    
    @objc func showList() {
        print("List button tapped")
    }
    
    // MARK: - UI Setup Methods
    
    private func setupProgressBar() {
        view.addSubview(progressBar)
        progressBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        
        // FIXME: Adjust by y
        progressBar.configure(current: 0, total: setCount, sidePadding: 16)
    }
    
    private func setupBadges() {
        availableMuscles = uniqueMuscles(from: exercises)
        guard !availableMuscles.isEmpty else { return }
        
        badgesScrollView.showsHorizontalScrollIndicator = false
        badgesScrollView.alwaysBounceHorizontal = true
        badgesScrollView.backgroundColor = .clear
        view.addSubview(badgesScrollView)
        
        badgesStackView.axis = .horizontal
        badgesStackView.alignment = .center
        badgesStackView.spacing = 8
        badgesStackView.backgroundColor = .clear
        badgesScrollView.addSubview(badgesStackView)
        
        badgesScrollView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
            make.height.equalTo(34)
        }
        
        badgesStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            make.height.equalToSuperview()
        }
        
        rebuildBadges()
    }
    
    private func rebuildBadges() {
        badgesStackView.arrangedSubviews.forEach { view in
            badgesStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        badgeButtonsByMuscleID.removeAll()
        filtersButton = nil
        
        if badgesExpanded {
            availableMuscles.forEach { muscle in
                let button = makeBadgeButton(title: muscle.getName())
                button.addTarget(self, action: #selector(badgeTapped(_:)), for: .touchUpInside)
                button.tag = availableMuscles.firstIndex(where: { $0.objectID == muscle.objectID }) ?? 0
                badgesStackView.addArrangedSubview(button)
                badgeButtonsByMuscleID[muscle.objectID] = button
            }
            updateBadgeStyles()
        } else {
            let filtersButton = makeBadgeButton(title: "")
            let filterSymbolConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .black, scale: .large)
            filtersButton.setImage(UIImage(systemName: "line.3.horizontal.decrease", withConfiguration: filterSymbolConfig)?.withRenderingMode(.alwaysTemplate), for: .normal)
            filtersButton.tintColor = .akGray
            filtersButton.imageView?.contentMode = .scaleAspectFit
            filtersButton.widthAnchor.constraint(equalToConstant: 54).isActive = true
            filtersButton.addTarget(self, action: #selector(filtersBadgeTapped), for: .touchUpInside)
            badgesStackView.addArrangedSubview(filtersButton)
            self.filtersButton = filtersButton
            DispatchQueue.main.async { [weak self] in
                self?.startFilterButtonShimmer()
            }
        }
    }
    
    private func startFilterButtonShimmer() {
        guard !hasShownFilterButtonShimmer, !badgesExpanded, let filtersButton else { return }
        filtersButton.layoutIfNeeded()
        guard filtersButton.bounds.width > 0 else { return }
        hasShownFilterButtonShimmer = true
        
        // Use a simple one-time white pulse instead of a moving gradient shimmer.
        filtersButton.layer.sublayers?.removeAll(where: { $0.name == "filterButtonShimmer" })
        UIView.animate(withDuration: 0.18, delay: 0.25, options: [.curveEaseOut]) {
            filtersButton.alpha = 0.55
        } completion: { _ in
            UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseIn]) {
                filtersButton.alpha = 1.0
            }
        }
    }
    
    private func makeBadgeButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        if #available(iOS 15.0, *) {
            button.configuration = nil
        }
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.cornerCurve = .continuous
        button.clipsToBounds = true
        button.setTitle(title, for: .normal)
        button.setTitleColor(.akGray, for: .normal)
        button.titleLabel?.font = AKFont.round(.black, 13)
        button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12)
        return button
    }
    
    private func uniqueMuscles(from exercises: [Exercise]) -> [Muscle] {
        var seenIDs = Set<NSManagedObjectID>()
        var muscles: [Muscle] = []
        
        exercises.forEach { exercise in
            exercise.getMuscles().forEach { muscle in
                guard !seenIDs.contains(muscle.objectID) else { return }
                seenIDs.insert(muscle.objectID)
                muscles.append(muscle)
            }
        }
        
        return muscles.sorted { $0.getName() < $1.getName() }
    }
    
    @objc private func filtersBadgeTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        badgesExpanded = true
        rebuildBadges()
    }
    
    @objc private func badgeTapped(_ sender: UIButton) {
        guard sender.tag >= 0 && sender.tag < availableMuscles.count else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        let muscle = availableMuscles[sender.tag]
        if selectedMuscleIDs.contains(muscle.objectID) {
            selectedMuscleIDs.remove(muscle.objectID)
        } else {
            selectedMuscleIDs.insert(muscle.objectID)
        }
        
        if selectedMuscleIDs.isEmpty {
            badgesExpanded = false
            rebuildBadges()
        } else {
            updateBadgeStyles()
        }
        applyExerciseFilter()
    }
    
    private func updateBadgeStyles() {
        badgeButtonsByMuscleID.forEach { muscleID, button in
            let isSelected = selectedMuscleIDs.contains(muscleID)
            button.backgroundColor = isSelected ? .black : .white
            button.setTitleColor(isSelected ? .white : .akGray, for: .normal)
        }
    }
    
    private func applyExerciseFilter() {
        honeycombGrid?.updateItemViews { [weak self] exercise, hexView in
            guard let self else { return }
            let isEnabled: Bool
            if selectedMuscleIDs.isEmpty {
                isEnabled = true
            } else {
                let exerciseMuscleIDs = Set(exercise.getMuscles().map { $0.objectID })
                isEnabled = !exerciseMuscleIDs.isDisjoint(with: selectedMuscleIDs)
            }
            
            UIView.transition(with: hexView, duration: 0.2, options: [.transitionCrossDissolve, .allowUserInteraction]) {
                if isEnabled {
                    hexView.configure(withExercise: exercise, andLog: self.log, inverted: true)
                } else {
                    hexView.configureDisabledWorkoutAppearance()
                }
            }
        }
    }
    
    private func setupTimerView() {
        timerView.frame = CGRect(x: 0, y: 0, width: 72, height: 40)
        timerView.backgroundColor = .clear
        timerView.configure(format: .minutesSeconds, textColor: .black, font: AKFont.round(.black, 18))
        
        let timerClickedTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTimerTap))
        timerView.addGestureRecognizer(timerClickedTapGestureRecognizer)
    }
    
    private func setupNavigationOverlay() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        navExitView?.removeFromSuperview()
        timerView.removeFromSuperview()
        
        // Remove any stale overlay views from previous layout passes/controller instances.
        navigationController?.navigationBar.viewWithTag(navTimerViewTag)?.removeFromSuperview()
        navigationController?.navigationBar.viewWithTag(navExitViewTag)?.removeFromSuperview()
        navigationController?.view.viewWithTag(navTimerViewTag)?.removeFromSuperview()
        navigationController?.view.viewWithTag(navExitViewTag)?.removeFromSuperview()
        
        guard let navigationBar = navigationController?.navigationBar else { return }
        timerView.tag = navTimerViewTag
        
        let exitView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        exitView.tag = navExitViewTag
        exitView.backgroundColor = .clear
        exitView.layer.backgroundColor = UIColor.clear.cgColor
        exitView.isOpaque = false
        exitView.isUserInteractionEnabled = true
        
        let imageView = UIImageView(image: UIImage.closeFat.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .akDark
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.isUserInteractionEnabled = false
        imageView.frame = CGRect(x: 13.5, y: 13.5, width: 17, height: 17)
        exitView.addSubview(imageView)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(xButtonHandler))
        exitView.addGestureRecognizer(tapRecognizer)
        
        navigationBar.addSubview(timerView)
        navigationBar.addSubview(exitView)
        navExitView = exitView
        positionNavigationOverlay()
        navigationBar.bringSubviewToFront(timerView)
        navigationBar.bringSubviewToFront(exitView)
    }
    
    private func positionNavigationOverlay() {
        guard let navigationBar = navigationController?.navigationBar,
              let navExitView else { return }
        
        timerView.frame = CGRect(
            x: 16,
            y: navigationBar.bounds.midY - 20,
            width: 72,
            height: 40
        )
        
        navExitView.frame = CGRect(
            x: navigationBar.bounds.maxX - 60,
            y: navigationBar.bounds.midY - 22,
            width: 44,
            height: 44
        )
        
        navigationBar.bringSubviewToFront(timerView)
        navigationBar.bringSubviewToFront(navExitView)
    }
    
    @objc func handleTimerTap() {
        guard !APP_IS_DEBUG else {
            alertDidTrigger()
            return
        }
        
        let picker = RestDurationPickerController(currentPick: timerTargetString) { str in
            self.timerTargetString = str
            
            let components = str.split(separator: " ")
            guard components.count == 2 else {
                print("Invalid format: expected 'number unit'")
                return
            }
            
            // Convert the first component to Int
            guard let number = Int(components[0]) else {
                print("Cannot convert \(components[0]) to Int")
                return
            }
            
            // Get the unit as String
            let unit = String(components[1])
            var numberAdjustedForUnit = number
            if unit == "m" {
                numberAdjustedForUnit = number * 60
            }
            
            self.timerTargetInt = numberAdjustedForUnit
        }
        
        navigationController?.present(picker, animated: true)
    }
    
    private var transitionDelegate: HexTransitionDelegate?
    private func setupHoneycombGrid() {
        // Keep hexagons unscaled. If there are many exercises, lay them out
        // horizontally and let the user scroll left/right instead of shrinking them.
        let hexSize: CGFloat = UIScreen.main.bounds.width/3
        
        // Create the honeycomb grid
        let honeycombGrid = HoneycombGridView<Exercise>(
            hexagonSize: hexSize,
            layoutMode: exercises.count > 12 ? .horizontalScroll(rows: 4) : .spiral,
            animatesPopIn: false,
            contentVerticalOffset: -48,
            textProvider: { $0.getName() }
        )
        
        view.addSubview(honeycombGrid)
        honeycombGrid.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            honeycombGrid.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 20),
            honeycombGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            honeycombGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            honeycombGrid.bottomAnchor.constraint(equalTo: badgesScrollView.topAnchor, constant: -12)
        ])
        
        // Configure with exercises
        honeycombGrid.configure(
            with: exercises,
            invertExerciseColors: true,
            onItemSelected: { [weak self] (selectedExercise, hex) in
                let hexFrame = hex.convert(hex.bounds, to: self?.view)
                self?.addCompletedExercise(selectedExercise)
                self!.popConfetti(on: hex)
                
                hex.bumpDots()
                
                hex.configure(withExercise: selectedExercise, andLog: self?.log, inverted: true)
                self?.startTimer()
                
                // Get the frame of the hex in the main view's coordinate system
                self?.progressBar.bump(after: 1.8, onCompletion: {
                    // Create and present the completion screen with custom transition
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                        guard let completionSkill = self?.completionSkill else { return }
                        let completionScreen = HexCompletionScreen(skill: completionSkill)
                        self?.transitionDelegate = HexTransitionDelegate(originFrame: hexFrame)
                        completionScreen.transitioningDelegate = self?.transitionDelegate
                        self?.present(completionScreen, animated: true)
                    }
                })
            }
        )
        
        self.honeycombGrid = honeycombGrid
    }
    
    private func popConfetti(on hex: HexagonItemView<Exercise>) {
        print("DEBUG: popConfetti called for \(hex.textLabel.text ?? "unknown")")
        
        // Get position with additional logging
        let hexFrame = hex.frame
        print("DEBUG: Hex frame: \(hexFrame)")
        
        // Ensure we have a valid superview
        guard let hexSuperview = hex.superview else {
            print("DEBUG: ERROR - Hex has no superview!")
            return
        }
        
        // Convert position with detailed logging
        let centerInSuperview = CGPoint(x: hexFrame.midX, y: hexFrame.midY)
        print("DEBUG: Center in superview: \(centerInSuperview)")
        
        let convertedPoint = hexSuperview.convert(centerInSuperview, to: view)
        print("DEBUG: Converted point: \(convertedPoint)")
        
        // Ensure confetti view is ready and visible
        confettiView.isHidden = false
        confettiView.alpha = 1.0
        
        // Important: Place the confetti view BEHIND the honeycomb grid
        // This ensures the confetti appears to come from behind the hex
//        if let honeycombGrid = honeycombGrid {
//            view.insertSubview(confettiView, belowSubview: honeycombGrid)
//        } else {
//            view.addSubview(confettiView)
//        }
        view.insertSubview(confettiView, belowSubview: progressBar)
        
        // Force layout if needed
        view.layoutIfNeeded()
        
        // Start the animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self = self else { return }
            self.confettiView.removalStartPoint = self.progressBar.previousDotCenterForCurrentStep(convertedTo: self.confettiView)
            self.confettiView.removalEndPoint = self.progressBar.currentDotCenter(convertedTo: self.confettiView)
            self.confettiView.startConfettiCannon(at: convertedPoint, keepOnScreen: true)
            
            // Add a subtle "pop" animation to the hex
            UIView.animate(withDuration: 0.15, animations: {
                hex.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    hex.transform = .identity
                }
            })
        }
    }

    private func startTimer() {
        timerView.reset()
        timerView.start(withAlertIn: timerTargetInt)
    }
    
    private func getPositionForHex(_ hex: HexagonItemView<Exercise>) -> CGPoint {
        // Get the frame of the hex in its own coordinate system
        let hexFrame = hex.frame
        
        // Convert the center point of the hex to the coordinate system of the view controller's view
        if let hexSuperview = hex.superview {
            // First convert to the superview's coordinate system
            let centerInSuperview = CGPoint(x: hexFrame.midX, y: hexFrame.midY)
            
            // Then convert from the superview's coordinate system to the view controller's view coordinate system
            return hexSuperview.convert(centerInSuperview, to: view)
        }
        
        // Fallback to the hex's center if conversion isn't possible
        return hex.center
    }
    
    private func addCompletedExercise(_ exercise: Exercise) {
        let eLog = DatabaseFacade.makeExerciseLog(forExercise: exercise)
        log.addToLoggedExercises(eLog)
    }
    
    private func showExerciseDetails(_ exercise: String) {
        // Example: Show an alert with the exercise details
        let alert = UIAlertController(
            title: "Exercise Selected",
            message: "You selected: \(exercise)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Start Exercise", style: .default))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

