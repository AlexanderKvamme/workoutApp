//
//  MusclePickerController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 22/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

/// Lets user select muscles for a workout/exercises
class MusclePickerController: UIViewController {
    
    // MARK: - Properties
    
    var showFooter: Bool
    
    fileprivate lazy var table: UITableView = {
        let t = UITableView(frame: .zero)
        t.register(PickerCell.self, forCellReuseIdentifier: "cellIdentifier")
        t.backgroundColor = .clear
        t.translatesAutoresizingMaskIntoConstraints = false
        t.clipsToBounds = true
        t.allowsMultipleSelection = false
        t.separatorStyle = .none
        t.dataSource = self
        t.delegate = self
        
        return t
    }()
    
    private lazy var footer: ButtonFooter = {
        let view = ButtonFooter(withColor: .secondary)
        view.approveButton.addTarget(self, action: #selector(confirmAndDismiss), for: .touchUpInside)
        view.cancelButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var header: TwoLabelStack = {
        let headerLabel = PickerHeader(text: "SELECT")
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return headerLabel
    }()
    
    var selectionChoices = [Muscle]()
    var selectedMuscles: [Muscle]! // used to refresh the picker after returning from making new exercise
    
    // Delegates
    weak var exerciseReceiver: ExerciseReceiver?
    weak var muscleReceiver: MuscleReceiver?
    
    // MARK: - Initializers
    
    init(title: String, subtitle: String, withPreselectedMuscles preselectedMuscles: [Muscle]?, showFooter: Bool = true) {
        // Setup available choices
        self.selectedMuscles = preselectedMuscles
        self.selectionChoices = DatabaseFacade.fetchMuscles(with: .name, ascending: true)
        self.showFooter = showFooter

        // Preselect
        if let preselections = preselectedMuscles {
            self.selectedMuscles = preselections
        }
        
        super.init(nibName: nil, bundle: nil)
        
        self.header.topLabel.text = title
        self.header.bottomLabel.text = subtitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        styleBackButton()
        addSubViewsAndConstraints()
        view.backgroundColor = .akLight
        
        // Preselect
        for muscle in selectedMuscles {
            selectMuscle(muscle)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        globalTabBar.hideIt()
        addLongPressGestureRecognizer()
        table.reloadData()
        view.setNeedsLayout()
        
        UIView.animate(withDuration: 0.5) {
            self.updateScrollingAndInsets()
        }
    }
    
    // MARK: - Methods
    
    // MARK: Helper methods
    
    func addSubViewsAndConstraints() {
        // Add header and table (always present)
        view.addSubview(header)
        view.addSubview(table)
        
        // Create constraint arrays to activate
        var constraints = [NSLayoutConstraint]()
        
        // Add header constraints
        constraints.append(contentsOf: [
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constant.components.headers.pickerHeader.topSpacing),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Conditionally add footer and its constraints
        if showFooter {
            view.addSubview(footer)
            
            // Add footer constraints
            constraints.append(contentsOf: [
                footer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                footer.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
            
            // Table constraints with footer
            constraints.append(contentsOf: [
                table.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 100),
                table.bottomAnchor.constraint(equalTo: footer.topAnchor, constant: -100),
                table.leftAnchor.constraint(equalTo: view.leftAnchor),
                table.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
        } else {
            // Table constraints without footer (extend to bottom of view)
            constraints.append(contentsOf: [
                table.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 100),
                table.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20), // Add some bottom margin
                table.leftAnchor.constraint(equalTo: view.leftAnchor),
                table.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
        }
        
        // Activate all constraints
        NSLayoutConstraint.activate(constraints)
        
        updateScrollingAndInsets()
    }

    
    @objc func dismissView() {
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
    
    private func updateScrollingAndInsets() {
        
        table.layoutIfNeeded()
        table.reloadData()
        
        // Disable scrolling if all content fits in the frame
        let tableHeight = table.frame.height
        let contentHeight = table.contentSize.height
        
        // Refactor the rest to another place and animate resizing
        if contentHeight > tableHeight {
            table.isScrollEnabled = true
            setTableInsets()
        } else {
            table.isScrollEnabled = false
            setTableInsets()
        }
    }
    
    /// Add insets top and bottom to keep it centered, if contentView is smaller than the tableView.
    private func setTableInsets() {
        let tableHeight = table.bounds.size.height
        let contentHeight = table.contentSize.height
        let calculatedContentHeight: CGFloat = CGFloat(table.numberOfRows(inSection: 0)) * Constant.pickers.rowHeight
        
        if tableHeight > contentHeight {
            let verticalInset = (tableHeight - calculatedContentHeight)/2
            table.contentInset = UIEdgeInsets(top: verticalInset, left: 0, bottom: verticalInset, right: 0)
        } else {
            table.contentInset = UIEdgeInsets.zero
        }
    }
    
    // MARK: Cell configuration methods
    
    /// Takes a indexpath, and makes it look selected or not depending on if its he of selected indexPaths
    fileprivate func configure(cellAt indexPath: IndexPath) {
        guard let cell = table.cellForRow(at: indexPath) as? PickerCell else { return }
            
        if selectedMuscles.contains(selectionChoices[indexPath.row]) {
            cell.label.font = Constant.components.exerciseTableCells.fontWhenSelected
            cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenSelected
        } else {
            cell.label.font = Constant.components.exerciseTableCells.fontWhenDeselected
            cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenDeselected
        }
    }
    
    /// Make look selecter or deselected
    fileprivate func configure(cell: PickerCell, at indexPath: IndexPath) {
        let muscle = selectionChoices[indexPath.row]
        
        if selectedMuscles.contains(muscle) {
            cell.label.font = Constant.components.exerciseTableCells.fontWhenSelected
            cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenSelected
        } else {
            cell.label.font = Constant.components.exerciseTableCells.fontWhenDeselected
            cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenDeselected
        }
    }
    
    fileprivate func selectMuscle( _ muscleToSelect: Muscle) {
        guard let indexOfExercise = selectionChoices.index(of: muscleToSelect) else {
            return
        }
        
        let indexPath = IndexPath(row: indexOfExercise, section: 0)
        table.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        configure(cellAt: indexPath)
    }
    
    private func drawDiagonalLineThroughTable() {
        
        let lineView = TriangleView()
        view.addSubview(lineView)
        view.sendSubviewToBack(lineView)

        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lineView.centerXAnchor.constraint(equalTo: table.centerXAnchor),
            lineView.centerYAnchor.constraint(equalTo: table.centerYAnchor),
            ])
    }
    
    // MARK: Gesture recognizer methods
    
    private func addLongPressGestureRecognizer() {
        let longpressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        table.addGestureRecognizer(longpressGR)
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            // Get the location of the long press in the table view
            let touchPoint = sender.location(in: table)
            
            // Try to get the index path of the cell that was long-pressed
            if let indexPath = table.indexPathForRow(at: touchPoint) {
                let longPressedMuscle = selectionChoices[indexPath.row]
                let deleteScreen = DeletePickableScreen(pickable: longPressedMuscle, completion: {
                    self.navigationController?.popViewController(animated: true)
                })
                self.present(deleteScreen, animated: true)
            }
        }
    }
    
    // MARK: Exit methods
    
    @objc func confirmAndDismiss() {
        
        guard selectedMuscles.count > 0 else {
            navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
            return
        }
        muscleReceiver?.receive(muscles: selectedMuscles)
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
}

// MARK: - Extensions

// MARK: TableView DataSource

extension MusclePickerController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as! PickerCell
        configure(cell: cell, at: indexPath)
        cell.label.text = selectionChoices[indexPath.row].name
        cell.label.applyCustomAttributes(.more)
        let muscleName = "\(selectionChoices[indexPath.row].name!)"
        cell.accessibilityIdentifier = "\(muscleName)-muscle-button" // "ARMS-muscle-button"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectionChoices.count
    }
}

// MARK: TableView Delegate

extension MusclePickerController: UITableViewDelegate {
    
    // Add/remove to selected and make it look selected/deselected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tappedMuscle = selectionChoices[indexPath.row]
        
        // If already selected: remove og make look unselected
        if let index = selectedMuscles.index(of: tappedMuscle) {
            // deselect
            selectedMuscles.remove(at: index)
            configure(cellAt: indexPath)
        } else {
            // select
            selectedMuscles.append(tappedMuscle)
            configure(cellAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.pickers.rowHeight
    }
}

// MARK: ExerciseEditorDataSource

protocol MuscleEditorDataSource: class {
    func removeFromDataSource(muscle: Muscle)
}

extension MusclePickerController: MuscleEditorDataSource {
    
    func removeFromDataSource(muscle: Muscle) {
        // Deselect if selected
        if selectedMuscles.contains(muscle) {
            if let indexOfExercise = selectedMuscles.index(of: muscle) {
                selectedMuscles.remove(at: indexOfExercise)
            }
        }
        
        // Remove from table and datasource
        if let index = selectionChoices.index(of: muscle) {
            let indexPath = IndexPath(row: index, section: 0)
            selectionChoices.remove(at: index)
            table.deleteRows(at: [indexPath], with: .fade)
        }
        table.reloadData()
    }
}

