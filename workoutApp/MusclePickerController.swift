//import UIKit
//
///// Protocol for entities that can be selected in pickers
//protocol Selectable: AnyObject {
//    var name: String? { get }
//}
//
//// Make sure both Muscle and Skill conform to Selectable
//extension Muscle: Selectable {}
//extension Skill: Selectable {}
//
///// Lets user select multiple entities (muscles or skills) for a workout/exercises
//class EntityPickerController<T: Selectable>: UIViewController, UITableViewDataSource, UITableViewDelegate, EntityEditorDataSource {
//    // Type alias for EntityEditorDataSource
//    typealias EntityType = T
//    
//    // MARK: - Properties
//    
//    var showFooter: Bool
//    
//    fileprivate lazy var table: UITableView = {
//        let t = UITableView(frame: .zero)
//        t.register(PickerCell.self, forCellReuseIdentifier: "cellIdentifier")
//        t.backgroundColor = .clear
//        t.translatesAutoresizingMaskIntoConstraints = false
//        t.clipsToBounds = true
//        t.allowsMultipleSelection = true // Enable multiple selection
//        t.separatorStyle = .none
//        t.dataSource = self
//        t.delegate = self
//        
//        return t
//    }()
//    
//    private lazy var footer: ButtonFooter = {
//        let view = ButtonFooter(withColor: .secondary)
//        view.approveButton.addTarget(self, action: #selector(confirmAndDismiss), for: .touchUpInside)
//        view.cancelButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        
//        return view
//    }()
//    
//    private lazy var header: TwoLabelStack = {
//        let headerLabel = PickerHeader(text: "SELECT")
//        headerLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        return headerLabel
//    }()
//    
//    var selectionChoices = [T]()
//    var selectedEntities: [T]! // used to refresh the picker after returning from making new entity
//    
//    // Delegates
//    weak var receiver: PickableReceiver?
//    
//    // Completion handler for when selection is confirmed
//    var onSelectionComplete: (([T]) -> Void)?
//    
//    // MARK: - Initializers
//    
//    init(title: String = "Pick", subtitle: String = "Something", withPreselectedEntities preselectedEntities: [T]?, showFooter: Bool = true, onSelectionComplete: (([T]) -> Void)? = nil) {
//        // Setup available choices
//        self.selectedEntities = preselectedEntities ?? []
//        self.showFooter = showFooter
//        self.onSelectionComplete = onSelectionComplete
//        
//        // Fetch appropriate entities based on type
//        if T.self == Muscle.self {
//            self.selectionChoices = DatabaseFacade.fetchMuscles(with: .name, ascending: true) as! [T]
//        } else if T.self == Skill.self {
//            self.selectionChoices = DatabaseFacade.fetchSkills(with: .name, ascending: true) as! [T]
//        }
//        
//        // Preselect
//        if let preselections = preselectedEntities {
//            self.selectedEntities = preselections
//        }
//        
//        super.init(nibName: nil, bundle: nil)
//        
//        self.header.topLabel.text = title
//        self.header.bottomLabel.text = subtitle
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - Life Cycle
//    
//    override func viewDidLoad() {
//        styleBackButton()
//        addSubViewsAndConstraints()
//        view.backgroundColor = .akLight
//        
//        // Preselect
//        for entity in selectedEntities {
//            selectEntity(entity)
//        }
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        globalTabBar.hideIt()
//        addLongPressGestureRecognizer()
//        table.reloadData()
//        view.setNeedsLayout()
//        
//        UIView.animate(withDuration: 0.5) {
//            self.updateScrollingAndInsets()
//        }
//    }
//    
//    // MARK: - Methods
//    
//    // MARK: Helper methods
//    
//    func addSubViewsAndConstraints() {
//        // Add header and table (always present)
//        view.addSubview(header)
//        view.addSubview(table)
//        
//        // Create constraint arrays to activate
//        var constraints = [NSLayoutConstraint]()
//        
//        // Add header constraints
//        constraints.append(contentsOf: [
//            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constant.components.headers.pickerHeader.topSpacing),
//            header.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//        ])
//        
//        // Conditionally add footer and its constraints
//        if showFooter {
//            view.addSubview(footer)
//            
//            // Add footer constraints
//            constraints.append(contentsOf: [
//                footer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//                footer.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//            ])
//            
//            // Table constraints with footer
//            constraints.append(contentsOf: [
//                table.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 100),
//                table.bottomAnchor.constraint(equalTo: footer.topAnchor, constant: -100),
//                table.leftAnchor.constraint(equalTo: view.leftAnchor),
//                table.rightAnchor.constraint(equalTo: view.rightAnchor)
//            ])
//        } else {
//            // Table constraints without footer (extend to bottom of view)
//            constraints.append(contentsOf: [
//                table.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 100),
//                table.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20), // Add some bottom margin
//                table.leftAnchor.constraint(equalTo: view.leftAnchor),
//                table.rightAnchor.constraint(equalTo: view.rightAnchor)
//            ])
//        }
//        
//        // Activate all constraints
//        NSLayoutConstraint.activate(constraints)
//        
//        updateScrollingAndInsets()
//    }
//    
//    @objc func dismissView() {
//        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
//    }
//    
//    private func updateScrollingAndInsets() {
//        table.layoutIfNeeded()
//        table.reloadData()
//        
//        // Disable scrolling if all content fits in the frame
//        let tableHeight = table.frame.height
//        let contentHeight = table.contentSize.height
//        
//        // Refactor the rest to another place and animate resizing
//        if contentHeight > tableHeight {
//            table.isScrollEnabled = true
//            setTableInsets()
//        } else {
//            table.isScrollEnabled = false
//            setTableInsets()
//        }
//    }
//    
//    /// Add insets top and bottom to keep it centered, if contentView is smaller than the tableView.
//    private func setTableInsets() {
//        let tableHeight = table.bounds.size.height
//        let contentHeight = table.contentSize.height
//        let calculatedContentHeight: CGFloat = CGFloat(table.numberOfRows(inSection: 0)) * Constant.pickers.rowHeight
//        
//        if tableHeight > contentHeight {
//            let verticalInset = (tableHeight - calculatedContentHeight)/2
//            table.contentInset = UIEdgeInsets(top: verticalInset, left: 0, bottom: verticalInset, right: 0)
//        } else {
//            table.contentInset = UIEdgeInsets.zero
//        }
//    }
//    
//    // MARK: Cell configuration methods
//    
//    /// Takes a indexpath, and makes it look selected or not depending on if its he of selected indexPaths
//    fileprivate func configure(cellAt indexPath: IndexPath) {
//        guard let cell = table.cellForRow(at: indexPath) as? PickerCell else { return }
//        
//        if isEntitySelected(selectionChoices[indexPath.row]) {
//            cell.label.font = Constant.components.exerciseTableCells.fontWhenSelected
//            cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenSelected
//        } else {
//            cell.label.font = Constant.components.exerciseTableCells.fontWhenDeselected
//            cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenDeselected
//        }
//    }
//    
//    /// Make look selected or deselected
//    fileprivate func configure(cell: PickerCell, at indexPath: IndexPath) {
//        let entity = selectionChoices[indexPath.row]
//        
//        if isEntitySelected(entity) {
//            cell.label.font = Constant.components.exerciseTableCells.fontWhenSelected
//            cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenSelected
//        } else {
//            cell.label.font = Constant.components.exerciseTableCells.fontWhenDeselected
//            cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenDeselected
//        }
//    }
//    
//    /// Helper method to check if an entity is selected
//    fileprivate func isEntitySelected(_ entity: T) -> Bool {
//        return selectedEntities.contains { $0 === entity }
//    }
//    
//    fileprivate func selectEntity(_ entityToSelect: T) {
//        guard let indexOfEntity = selectionChoices.firstIndex(where: { $0 === entityToSelect }) else {
//            return
//        }
//        
//        let indexPath = IndexPath(row: indexOfEntity, section: 0)
//        table.selectRow(at: indexPath, animated: false, scrollPosition: .none)
//        configure(cellAt: indexPath)
//    }
//    
//    private func drawDiagonalLineThroughTable() {
//        let lineView = TriangleView()
//        view.addSubview(lineView)
//        view.sendSubviewToBack(lineView)
//        
//        lineView.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            lineView.centerXAnchor.constraint(equalTo: table.centerXAnchor),
//            lineView.centerYAnchor.constraint(equalTo: table.centerYAnchor),
//        ])
//    }
//    
//    // MARK: Gesture recognizer methods
//    
//    private func addLongPressGestureRecognizer() {
//        let longpressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
//        table.addGestureRecognizer(longpressGR)
//    }
//    
//    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
//        if sender.state == .began {
//            // Get the location of the long press in the table view
//            let touchPoint = sender.location(in: table)
//            
//            // Try to get the index path of the cell that was long-pressed
//            if let indexPath = table.indexPathForRow(at: touchPoint) {
//                let longPressedEntity = selectionChoices[indexPath.row]
//                // We need to cast to Pickable here since we're not requiring T to conform to Pickable
//                print("FIXME delete")
////                if let pickable = longPressedEntity as? Pickable {
////                    let deleteScreen = DeletePickableScreen(pickable: pickable, completion: {
////                        self.navigationController?.popViewController(animated: true)
////                    })
////                    self.present(deleteScreen, animated: true)
////                }
//            }
//        }
//    }
//    
//    // MARK: Exit methods
//    
//    @objc func confirmAndDismiss() {
//        guard selectedEntities.count > 0 else {
//            navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
//            return
//        }
//        
//        // Call the completion handler with the selected entities
//        onSelectionComplete?(selectedEntities)
//        
//        // For backward compatibility with the original MusclePickerController
//        if T.self == Muscle.self {
//            if let muscleReceiver = exerciseReceiver as? MuscleReceiver {
//                muscleReceiver.receive(muscles: selectedEntities as! [Muscle])
//            }
//        } else if T.self == Skill.self {
//            if let skillReceiver = exerciseReceiver as? SkillReceiver {
//                skillReceiver.receive(skills: selectedEntities as! [Skill])
//            }
//        }
//        
//        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
//    }
//    
//    // MARK: - UITableViewDataSource
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as! PickerCell
//        configure(cell: cell, at: indexPath)
//        cell.label.text = selectionChoices[indexPath.row].name
//        cell.label.applyCustomAttributes(.more)
//        
//        let entityName = "\(selectionChoices[indexPath.row].name ?? "")"
//        let entityType = T.self == Muscle.self ? "muscle" : "skill"
//        cell.accessibilityIdentifier = "\(entityName)-\(entityType)-button"
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return selectionChoices.count
//    }
//    
//    // MARK: - UITableViewDelegate
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let tappedEntity = selectionChoices[indexPath.row]
//        
//        // If already selected: remove and make look unselected
//        if let index = selectedEntities.firstIndex(where: { $0 === tappedEntity }) {
//            // deselect
//            selectedEntities.remove(at: index)
//            tableView.deselectRow(at: indexPath, animated: true)
//        } else {
//            // select
//            selectedEntities.append(tappedEntity)
//        }
//        
//        configure(cellAt: indexPath)
//    }
//    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        // This is called when a row is deselected
//        // We handle selection/deselection in didSelectRowAt, so we don't need to do anything here
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return Constant.pickers.rowHeight
//    }
//    
//    // MARK: - EntityEditorDataSource
//    
//    func removeFromDataSource(entity: T) {
//        // Deselect if selected
//        if let indexOfEntity = selectedEntities.firstIndex(where: { $0 === entity }) {
//            selectedEntities.remove(at: indexOfEntity)
//        }
//        
//        // Remove from table and datasource
//        if let index = selectionChoices.firstIndex(where: { $0 === entity }) {
//            let indexPath = IndexPath(row: index, section: 0)
//            selectionChoices.remove(at: index)
//            table.deleteRows(at: [indexPath], with: .fade)
//        }
//        table.reloadData()
//    }
//}
//
//// MARK: - Required Protocols
//
//protocol EntityEditorDataSource: AnyObject {
//    associatedtype EntityType: Selectable
//    func removeFromDataSource(entity: EntityType)
//}
