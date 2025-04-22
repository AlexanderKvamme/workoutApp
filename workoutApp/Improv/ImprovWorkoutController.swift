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
        
        // Example: Generate some exercise names for this muscle group
        // In a real app, you would fetch these from your database
        let baseName = muscleGroup.name ?? "Exercise"
        exercises = [
            "\(baseName) Push",
            "\(baseName) Pull",
            "\(baseName) Lift",
            "\(baseName) Hold",
            "\(baseName) Stretch"
        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // This ensures the honeycomb grid is laid out after the view's bounds are finalized
        honeycombGrid?.setNeedsLayout()
    }
    
    private func setupView() {
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = muscleGroup.name
        titleLabel.font = AKFont.round(.bold, 24)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the honeycomb grid with smaller hexagons
        let honeycombGrid = HoneycombGridView<String>(
            hexagonSize: UIScreen.main.bounds.width/4, // Smaller hexagons
            textProvider: { $0 }
        )
        
        view.addSubview(honeycombGrid)
        honeycombGrid.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            honeycombGrid.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            honeycombGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            honeycombGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            honeycombGrid.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Force layout to ensure the grid has a valid size
        view.layoutIfNeeded()
        
        print("Exercise honeycomb grid frame after layout: \(honeycombGrid.frame)")
        
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
//import AKKIT
//
//
//// MARK: - ImprovWorkoutController
//class ImprovWorkoutController: UIViewController {
//    private let muscleGroup: Muscle
//    
//    init(muscleGroup: Muscle) {
//        self.muscleGroup = muscleGroup
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .akLight
//        
//        // Set up the view with the selected muscle group
//        setupView()
//        styleBackButton()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
//    
//    private func setupView() {
//        // Title label
//        let titleLabel = UILabel()
//        titleLabel.text = muscleGroup.name
//        titleLabel.font = AKFont.round(.bold, 24)
//        titleLabel.textColor = .white
//        titleLabel.textAlignment = .center
//        
//        view.addSubview(titleLabel)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
//        ])
//        
//        // Add more UI components as needed for your workout view
//    }
//}
