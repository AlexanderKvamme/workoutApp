import UIKit
import AKKIT



// MARK: - HoneycombViewController
class HoneycombViewController: SelectionViewController {
    
    private var honeycombGrid: HoneycombGridView<Muscle>!
    private var muscleGroups: [Muscle] = []
    
    init() {
        super.init(header: SelectionViewHeader(header: "Improvise workout", subheader: "Select a skill"))
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        
        let skill = DatabaseFacade.makeSkill()
        skill.title = "Caseman"
        let skill2 = DatabaseFacade.makeSkill()
        skill2.title = "The fuckening"
        
        let skills = DatabaseFacade.fetchSkills()
        print("shazam skills: ", skills.count)
        print("shazam skills: ", skills.map{ $0.title })
        
        for skill in skills {
            DatabaseFacade.delete(skill)
        }
        
        DatabaseFacade.saveContext()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        muscleGroups = DatabaseFacade.fetchMuscles()
        reset()
        setupHoneycombGrid()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // Hide the navigation bar
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//        if let customTabBarController = self.tabBarController as? CustomTabBarController {
//            customTabBarController.hideSelectionIndicator(shouldAnimate: true)
//            navigationController?.setNavigationBarHidden(true, animated: true)
//        }
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // This ensures the honeycomb grid is laid out after the view's bounds are finalized
        honeycombGrid?.setNeedsLayout()
    }
    
    private func reset() {
        if honeycombGrid != nil {
            honeycombGrid.reset()
            honeycombGrid.removeFromSuperview()
        }
    }
    
    private func setupHoneycombGrid() {
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
        
        // Configure with data and selection handler
        honeycombGrid.configure(with: muscleGroups) { [weak self] (selectedMuscle, hexView: HexagonItemView) in
            print("Selected muscle: \(selectedMuscle.name ?? "Unknown")")
            let improvWorkoutController = ImprovWorkoutController(muscleGroup: selectedMuscle)
            self?.navigationController?.pushViewController(improvWorkoutController, animated: true)
        }
    }
}

