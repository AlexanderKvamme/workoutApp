import UIKit
import AKKIT
import CoreData

// MARK: - ImprovWorkoutController
class ImprovWorkoutController: UIViewController {
    private let muscleGroup: Muscle
    private var honeycombGrid: HoneycombGridView<Exercise>?
    private var exercises: [Exercise] = []
    private var progressBar = DotProgressView()
    private var confettiView: ConfettiView!
    private var timerView = TimerView()
    private var log: WorkoutLog!

    init(muscleGroup: Muscle) {
        self.muscleGroup = muscleGroup
        
        super.init(nibName: nil, bundle: nil)
        
        let dbExercises = DatabaseFacade.fetchExercises(containing: muscleGroup) ?? []
        print("exercises: ", (dbExercises ?? []).map {$0.name ?? "NA" })
        exercises = dbExercises.map { $0 }
        
        let baseName = muscleGroup.name ?? "Exercise"
        title = baseName
        
        let listButton = UIBarButtonItem(
            image: UIImage(systemName: "list.bullet")?.withRenderingMode(.alwaysOriginal).withTintColor(.black),
            style: .plain,
            target: self,
            action: #selector(showList)
        )

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationItem.hidesBackButton = false
        self.navigationItem.rightBarButtonItem = listButton
        self.navigationController?.navigationBar.tintColor = .black
        
        let wStyle = DatabaseFacade.getWorkoutStyle(named: "IMPROV") ?? DatabaseFacade.makeWorkoutStyle(named: "IMPROV")
        DatabaseFacade.makeWorkout(withName: "Improv",
                                   workoutStyle: wStyle,
                                   muscles: [muscleGroup],
                                   exercises: []) // FIXME: Start empty
        let workout = DatabaseFacade.makeWorkout()
        private var log = DatabaseFacade.makeWorkoutLog(ofDesign: <#T##Workout#>)

        // FIXME: Figure out a way of how to add exercises?
        
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
        
        // Make sure navigation bar is visible
        navigationController?.setNavigationBarHidden(true, animated: false)
//        navigationController?.navigationBar.isHidden = false
        
        // Ensure back button is visible
        navigationItem.hidesBackButton = false
        
        styleBackButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // This ensures the honeycomb grid is laid out after the view's bounds are finalized
        honeycombGrid?.setNeedsLayout()
        
        // Make sure confetti view covers the entire screen
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
                self?.popConfetti(on: hex)
                
                hex.bumpStripes() // Move into configure?
                print("bam IWC had log: ", log)
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
        let pos = getPositionForHex(hex)
        confettiView.startConfettiCannon(at: pos)
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
