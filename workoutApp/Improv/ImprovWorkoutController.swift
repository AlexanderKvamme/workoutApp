import UIKit
import AKKIT

// MARK: - ImprovWorkoutController
class ImprovWorkoutController: UIViewController {
    private let muscleGroup: Muscle
    private var honeycombGrid: HoneycombGridView<String>?
    private var exercises: [String] = []
    
    init(muscleGroup: Muscle) {
        self.muscleGroup = muscleGroup
        super.init(nibName: nil, bundle: nil)
        
        let dbExercises = DatabaseFacade.fetchExercises(containing: muscleGroup) ?? []
        print("exercises: ", (dbExercises ?? []).map {$0.name ?? "NA" })
        exercises = dbExercises.map { $0.getName() }
        
        // Example: Generate some exercise names for this muscle group
        // In a real app, you would fetch these from your database
        let baseName = muscleGroup.name ?? "Exercise"
        title = baseName
        
//        exercises = [
//            "\(baseName) Push",
//            "\(baseName) Pull",
//            "\(baseName) Lift",
//            "\(baseName) Hold",
//            "\(baseName) Stretch"
//        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        setupView()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationItem.hidesBackButton = false
        
        styleBackButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // This ensures the honeycomb grid is laid out after the view's bounds are finalized
        honeycombGrid?.setNeedsLayout()
    }
    
    private func setupView() {
        // Create the honeycomb grid with smaller hexagons
        let honeycombGrid = HoneycombGridView<String>(
            hexagonSize: UIScreen.main.bounds.width/4, // Smaller hexagons
            textProvider: { $0 }
        )
        
        view.addSubview(honeycombGrid)
        honeycombGrid.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            honeycombGrid.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            honeycombGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            honeycombGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            honeycombGrid.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Force layout to ensure the grid has a valid size
        view.layoutIfNeeded()
        
        // Configure with exercises
        honeycombGrid.configure(with: exercises) { [weak self] selectedExercise in
            print("Selected exercise: \(selectedExercise)")
            // Handle exercise selection - perhaps start the exercise or show details
            self?.showExerciseDetails(selectedExercise)
        }
        
        self.honeycombGrid = honeycombGrid
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
