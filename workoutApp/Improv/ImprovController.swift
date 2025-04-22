import UIKit
import AKKIT



// MARK: - HoneycombViewController
class HoneycombViewController: SelectionViewController {
    private var honeycombGrid: HoneycombGridView<Muscle>!
    private var muscleGroups: [Muscle] = []
    
    init() {
        super.init(header: SelectionViewHeader(header: "Improv", subheader: "Today"))
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        
        // Get data from database
        muscleGroups = DatabaseFacade.fetchMuscles()
        let muscleNames = muscleGroups.map { $0.name ?? "NA" }
        print("bam muscles: ", muscleNames)
        
        setupHoneycombGrid()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if let customTabBarController = self.tabBarController as? CustomTabBarController {
            customTabBarController.hideSelectionIndicator(shouldAnimate: true)
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // This ensures the honeycomb grid is laid out after the view's bounds are finalized
        honeycombGrid?.setNeedsLayout()
    }
    
    private func setupHoneycombGrid() {
        print("Setting up honeycomb grid")
        
        // Create the honeycomb grid with a text provider
        honeycombGrid = HoneycombGridView<Muscle>(textProvider: { muscle in
            return muscle.name ?? "Unknown"
        })
        
        // Add to view and set constraints
        view.addSubview(honeycombGrid)
        honeycombGrid.translatesAutoresizingMaskIntoConstraints = false
        
        // Set explicit constraints to ensure the grid has a non-zero size
        NSLayoutConstraint.activate([
            honeycombGrid.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100), // Give space for header
            honeycombGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            honeycombGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            honeycombGrid.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Force layout to ensure the grid has a valid size
        view.layoutIfNeeded()
        
        print("Honeycomb grid frame after layout: \(honeycombGrid.frame)")
        
        // Configure with data and selection handler
        honeycombGrid.configure(with: muscleGroups) { [weak self] selectedMuscle in
            print("Selected muscle: \(selectedMuscle.name ?? "Unknown")")
            let improvWorkoutController = ImprovWorkoutController(muscleGroup: selectedMuscle)
            self?.navigationController?.pushViewController(improvWorkoutController, animated: true)
        }
    }
}

