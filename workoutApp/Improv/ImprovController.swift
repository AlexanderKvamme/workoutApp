import UIKit
import AKKIT



// MARK: - HoneycombViewController
class HoneycombViewController: SelectionViewController {
    
    private var honeycombGrid: HoneycombGridView<Skill>!
    private var skills: [Skill] = []
    
    init() {
        super.init(header: SelectionViewHeader(header: "Practice", subheader: " a skill "))
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        
        DatabaseFacade.saveContext()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        skills = DatabaseFacade.fetchSkills()
        
        reset()
        setupHoneycombGrid()
        
//        let skill = skills.first(where: { $0.getName() == "HANDSTAND" })!
//        let improvWorkoutController = ImprovWorkoutController(skill: skill)
//        navigationController?.pushViewController(improvWorkoutController, animated: true)
        globalTabBar.showIt()
        header.play()
    }
    
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
        honeycombGrid = HoneycombGridView<Skill>(textProvider: { muscle in
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
        honeycombGrid.configure(with: skills) { [weak self] (selectedSkill, hexView: HexagonItemView) in
            let setCountPicker = SetCountPickerController(skill: selectedSkill) { setCount in
                // Create your custom view controller with the selected skill and set count
                let improvWorkoutController = ImprovWorkoutController(skill: selectedSkill)
                improvWorkoutController.setCount = setCount
                self?.navigationController?.pushViewController(improvWorkoutController, animated: true)
                print("Selected \(setCount) sets for skill: \(selectedSkill.name ?? "Unknown")")
            }
            
            self?.present(setCountPicker, animated: true)
        }
    }
}

