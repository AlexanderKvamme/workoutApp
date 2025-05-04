import UIKit
import AKKIT
import CoreData

// MARK: - ImprovWorkoutController
class ImprovWorkoutController: UIViewController {
    private let skill: Skill
    private var honeycombGrid: HoneycombGridView<Exercise>?
    private var exercises: [Exercise] = []
    private var progressBar = DotProgressView()
    private var confettiView: ConfettiView!
    private var timerView = TimerView()
    private var log: WorkoutLog!

    init(skill: Skill) {
        self.skill = skill
        
        super.init(nibName: nil, bundle: nil)
        
        let wStyle = DatabaseFacade.getWorkoutStyle(named: "IMPROV") ?? DatabaseFacade.makeWorkoutStyle(named: "IMPROV")
        let workout = DatabaseFacade.makeWorkout(withName: "Improv",
                                   workoutStyle: wStyle,
                                   muscles: [],
                                   skills: [skill], // FIXME: Is this ok?
                                   exercises: []) // FIXME: Start empty
        // FIXME: Figure out a way of how to add exercises?
        self.log = DatabaseFacade.makeWorkoutLog(ofDesign: workout)
        let dbExercises = skill.getExercises()
        exercises = dbExercises.map { $0 }
        
        let baseName = skill.name ?? "Exercise"
        title = baseName
        
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

//        styleBackButton()
        addExitButtonToNavBar()
        
        // Make sure navigation bar is visible
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationItem.hidesBackButton = true
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        progressBar.configure(current: 0, total: 9)
    }
    
    private func setupTimerView() {
        view.addSubview(timerView)
        timerView.snp.makeConstraints { make in
            make.top.equalTo(progressBar)
            make.left.equalTo(progressBar.snp.right).offset(-10)
            make.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        timerView.configure(format: .minutesSeconds, textColor: .black)
    }
    
    private func setupHoneycombGrid() {
        // Adaptive sizing based on number of exercises
        let hexSize: CGFloat
        if exercises.count <= 6 {
            hexSize = UIScreen.main.bounds.width/2.5  // Larger hexagons for fewer exercises
        } else if exercises.count <= 12 {
            hexSize = UIScreen.main.bounds.width/3    // Medium hexagons
        } else {
            hexSize = UIScreen.main.bounds.width/4    // Smaller hexagons for many exercises
        }
        
        // Create the honeycomb grid
        let honeycombGrid = HoneycombGridView<Exercise>(
            hexagonSize: hexSize,
            textProvider: { $0.getName() }
        )
        
        view.addSubview(honeycombGrid)
        honeycombGrid.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            honeycombGrid.topAnchor.constraint(equalTo: timerView.bottomAnchor, constant: 20),
            honeycombGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            honeycombGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            honeycombGrid.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Configure with exercises
        honeycombGrid.configure(
            with: exercises,
            onItemSelected: { [weak self] (selectedExercise, hex) in
                self?.addCompletedExercise(selectedExercise)
                self!.popConfetti(on: hex)
                
//                hex.bumpStripes() // Move into configure?
                hex.bumpDots()
                
//                print("bam IWC had log: ", self?.log)
                hex.configure(withExercise: selectedExercise, andLog: self?.log)
                self?.startTimer()
            },
            onItemLongPressed: { [weak self] (selectedExercise, item) in
                print("LONG PRESSED: \(selectedExercise)")
                
                // Start the timer when long pressed
//                self?.timerView.start()
                
                // You can also add other actions here
                // self?.addCompletedExercise(selectedExercise)
                // let pos = self?.getPositionForExercise(selectedExercise)
                // self?.confettiView.startConfettiCannon(at: pos!)
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
        if let honeycombGrid = honeycombGrid {
            view.insertSubview(confettiView, belowSubview: honeycombGrid)
        } else {
            view.addSubview(confettiView)
        }
        
        // Force layout if needed
        view.layoutIfNeeded()
        
        // Start the animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self = self else { return }
            self.confettiView.startConfettiCannon(at: convertedPoint)
            
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
        timerView.start()
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
        progressBar.bump()
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


