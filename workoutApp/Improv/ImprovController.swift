import UIKit
import AKKIT



private enum PracticeSkillGridItem {
    case all
    case skill(Skill)
    
    var title: String {
        switch self {
        case .all:
            return "ALL"
        case .skill(let skill):
            return skill.name ?? "Unknown"
        }
    }
}

// MARK: - HoneycombViewController
class HoneycombViewController: SelectionViewController {
    
    private var honeycombGrid: HoneycombGridView<PracticeSkillGridItem>!
    private var skills: [Skill] = []
    
    init() {
        super.init(header: AnimatedScreenHeader(header: "Skill", subheader: "practice"))
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
        honeycombGrid = HoneycombGridView<PracticeSkillGridItem>(textProvider: { item in
            return item.title
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
        let gridItems: [PracticeSkillGridItem] = [.all] + skills.map { .skill($0) }
        honeycombGrid.configure(with: gridItems) { [weak self] selectedItem, hexView in
            guard let self else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

            switch selectedItem {
            case .skill(let selectedSkill) where selectedSkill.getExercises().isEmpty:
                let improvWorkoutController = ImprovWorkoutController(skill: selectedSkill)
                self.navigationController?.pushViewController(improvWorkoutController, animated: true)
            default:
                let setCountPicker = SetCountPickerController(title: selectedItem.title) { setCount in
                    let improvWorkoutController: ImprovWorkoutController
                    switch selectedItem {
                    case .all:
                        improvWorkoutController = ImprovWorkoutController(skills: self.skills)
                    case .skill(let selectedSkill):
                        improvWorkoutController = ImprovWorkoutController(skill: selectedSkill)
                    }
                    improvWorkoutController.setCount = setCount
                    self.navigationController?.pushViewController(improvWorkoutController, animated: true)
                }
                self.present(setCountPicker, animated: true)
            }
        }
    }
}

