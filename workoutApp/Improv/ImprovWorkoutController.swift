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
    private var confettiView: ConfettiView!
    var timerView = TimerView()
    private var log: WorkoutLog!
    
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
        setupProgressBar()
        setupTimerView()
        setupHoneycombGrid()

        addExitButtonToNavBar()
        
        // Make sure navigation bar is visible
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationItem.hidesBackButton = true
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if progressBar.currentStep == progressBar.totalSteps {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // This ensures the honeycomb grid is laid out after the view's bounds are finalized
        honeycombGrid?.setNeedsLayout()
        confettiView.frame = view.bounds
    }
    
    @objc func showList() {
        print("List button tapped")
    }
    
    // MARK: - UI Setup Methods
    
    private func setupProgressBar() {
        view.addSubview(progressBar)
        progressBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(40)
        }
        
        // FIXME: Adjust by y
        progressBar.configure(current: 0, total: setCount)
    }
    
    private func setupTimerView() {
        view.addSubview(timerView)
        timerView.snp.makeConstraints { make in
            make.top.equalTo(progressBar)
            make.right.equalToSuperview().inset(24)
            make.height.equalTo(40)
        }
//        timerView.snp.makeConstraints { make in
//            make.top.equalTo(progressBar)
//            make.right.equalToSuperview().inset(24)
//            make.height.equalTo(40)
//            // Optional: Set a fixed width if the timer should have consistent sizing
////            make.width.equalTo(64) // Adjust based on your design
//        }
        
        timerView.configure(format: .minutesSeconds, textColor: .black)
        
        let timerClickedTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTimerTap))
        timerView.addGestureRecognizer(timerClickedTapGestureRecognizer)
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
            textProvider: { $0.getName() }
        )
        
        view.addSubview(honeycombGrid)
        honeycombGrid.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            honeycombGrid.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 20),
            honeycombGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            honeycombGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            honeycombGrid.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Configure with exercises
        honeycombGrid.configure(
            with: exercises,
            onItemSelected: { [weak self] (selectedExercise, hex) in
                let hexFrame = hex.convert(hex.bounds, to: self?.view)
                self?.addCompletedExercise(selectedExercise)
                self!.popConfetti(on: hex)
                
                hex.bumpDots()
                
                hex.configure(withExercise: selectedExercise, andLog: self?.log)
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
            self.confettiView.removalPoint = progressBar.center
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

