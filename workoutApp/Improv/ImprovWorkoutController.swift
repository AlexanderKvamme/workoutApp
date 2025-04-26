import UIKit
import AKKIT

// MARK: - ImprovWorkoutController
class ImprovWorkoutController: UIViewController {
    private let muscleGroup: Muscle
    private var honeycombGrid: HoneycombGridView<String>?
    private var exercises: [String] = []
    private var progressBar = DotProgressView()
    private var confettiView: ConfettiView!
    
    init(muscleGroup: Muscle) {
        self.muscleGroup = muscleGroup
        super.init(nibName: nil, bundle: nil)
        
        let dbExercises = DatabaseFacade.fetchExercises(containing: muscleGroup) ?? []
        print("exercises: ", (dbExercises ?? []).map {$0.name ?? "NA" })
        exercises = dbExercises.map { $0.getName() }
        
        let baseName = muscleGroup.name ?? "Exercise"
        title = baseName
        
        let listButton = UIBarButtonItem(
            image: UIImage(systemName: "list.bullet")?.withRenderingMode(.alwaysOriginal).withTintColor(.black),
            style: .plain,
            target: self,
            action: #selector(showList)
        )

        self.navigationItem.rightBarButtonItem = listButton
        self.navigationController?.navigationBar.tintColor = .black
        
        setup()
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
        
        setupView()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationItem.hidesBackButton = false
        
        styleBackButton()
        
        setup()
    }
    
    private func setup() {
        view.addSubview(progressBar)
        progressBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(64)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        progressBar.configure(current: 0, total: 9)
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
    
    private func setupView() {
        // Create the honeycomb grid with smaller hexagons
        let honeycombGrid = HoneycombGridView<String>(
            hexagonSize: UIScreen.main.bounds.width/4,
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
        honeycombGrid.configure(
            with: exercises,
            onItemSelected: { [weak self] selectedExercise in
                self?.addCompletedExercise(selectedExercise)
                let pos = self?.getPositionForExercise(selectedExercise)
                self?.confettiView.startConfettiCannon(at: pos!)
            },
            onItemLongPressed: { [weak self] selectedExercise in
//                print("LONG PRESSED: \(selectedExercise)")
//                self?.addCompletedExercise(selectedExercise)
//                
//                // Get the position of the selected exercise in the honeycomb grid
//                let test = self?.getPositionForExercise(selectedExercise)
//                self?.confettiView.startConfettiCannon(at: test!)
            }
        )
        
        self.honeycombGrid = honeycombGrid
    }
    
    private func getPositionForExercise(_ exercise: String) -> CGPoint {
        // This is a simplified approach - you may need to adjust this based on your HoneycombGridView implementation
        // Ideally, your HoneycombGridView should provide a way to get the center position of a specific cell
        
        // For now, let's use the center of the view as a fallback
        return view.center
    }
    
    private func addCompletedExercise(_ exercise: String) {
        print("bam would add ", exercise)
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
