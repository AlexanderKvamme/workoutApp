//
//  WorkoutPickerViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 26/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

/// Used to pick and return selection of any number of exercises
class ExercisePickerController: UIViewController {
    
    // MARK: - Properties
    
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
        view.frame = CGRect(x: 0, y: view.frame.origin.y, width: view.frame.width, height: view.frame.height*1.5)
        view.cancelButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        view.approveButton.addTarget(self, action: #selector(confirmAndDismiss), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var header: TwoLabelStack = {
        let headerLabel = PickerHeader(text: "SELECT EXERCISES")
        var subheaderText = ""
        var muscleName = self.selectedMuscles.getName()
        subheaderText = muscleName == "MULTIPLE" ? "FOR SELECTED EXERCISES" : "\(muscleName)"
        headerLabel.setBottomText(subheaderText)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return headerLabel
    }()
    
    private lazy var plusButton: UIButton = {
        let button = PlusButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(presentNewExerciseController), for: .touchUpInside)
        return button
    }()
    
    var selectionChoices = [Exercise]()
    var selectedExercises = [Exercise]()
    var selectedMuscles: [Muscle]! // used to refresh the picker after returning from making new exercise
    
    // Delegates
    weak var exerciseReceiver: ExerciseReceiver?
    weak var pickableReceiver: PickableReceiver?
    
    // MARK: - Initializers
    
    init(forMuscle muscles: [Muscle], withPreselectedExercises preselectedExercises: [Exercise]?) {
        self.selectedMuscles = muscles
        var exercises = [Exercise]()

        // Add muscles
        for muscle in muscles {
            let musclesExercises = DatabaseFacade.fetchExercises(containing: muscle)!
            exercises.append(contentsOf: musclesExercises)
        }
        
        // Remove duplicates
        let exercisesAsSet = Set(exercises)
        exercises = Array(exercisesAsSet)
        
        selectionChoices = exercises.sortedByName()
        
        // Preselect
        if let preselections = preselectedExercises {
            self.selectedExercises = preselections
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        addSubViewsAndConstraints()
        view.backgroundColor = .akLight
        
        // Preselect
        for exercise in selectedExercises {
            selectExercise(exercise)
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

    @objc private func presentNewExerciseController() {
        
        let newExerciseController = NewExerciseController(withPreselectedMuscle: selectedMuscles)
        newExerciseController.exercisePickerDelegate = self
        navigationController?.pushViewController(newExerciseController, animated: Constant.Animation.pickerVCsShouldAnimateIn)
    }
    
    private func addSubViewsAndConstraints() {
        view.addSubview(header)
        view.addSubview(footer)
        view.addSubview(table)
        view.addSubview(plusButton)
        
        let plusButtonTopSpacing = Constant.UI.headers.headerToPlusButtonSpacing
        
        NSLayoutConstraint.activate([
            // Footer
            footer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            // Header
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: Constant.components.headers.pickerHeader.topSpacing),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            // "+" button
            plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plusButton.topAnchor.constraint(equalTo: header.bottomAnchor, constant: plusButtonTopSpacing),
            // Table
            table.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 100),
            table.bottomAnchor.constraint(equalTo: footer.topAnchor, constant: -100),
            table.leftAnchor.constraint(equalTo: view.leftAnchor),
            table.rightAnchor.constraint(equalTo: view.rightAnchor),
            ])
        
        updateScrollingAndInsets()
    }
    
    @objc func dismissView() {
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
    
    // MARK: Delegate methods
    
    private func updateScrollingAndInsets() {
        table.layoutIfNeeded()
        table.reloadData()
        
        updateScrollable()
    }
    
    private func updateScrollable() {
        // Disable scrolling if all content fits in the frame
        let tableHeight = table.frame.height
        let contentHeight = table.contentSize.height
        
        if contentHeight > tableHeight {
            table.isScrollEnabled = true
            setTableInsets()
        } else {
            table.isScrollEnabled = false
            setTableInsets()
        }
    }
    
    /// If contentView is smaller than the tableView. Add insets top and bottom to keep it centered.
    private func setTableInsets() {
        let tableHeight = table.frame.size.height
        let contentHeight: CGFloat = Constant.pickers.rowHeight * CGFloat(table.numberOfRows(inSection: 0))
        
        if tableHeight > contentHeight {
            let insets = (tableHeight-contentHeight)/2
            table.contentInset = UIEdgeInsets(top: insets, left: 0, bottom: insets, right: 0)
        } else {
            table.contentInset = UIEdgeInsets.zero
        }
    }
    
    // MARK: Cell configuration methods
    
    /// Takes a indexpath, and makes it look selected or not depending on if its he of selected indexPaths
    fileprivate func configure(cellAt indexPath: IndexPath) {
        
        guard let cell = table.cellForRow(at: indexPath) as? PickerCell else {
            return
        }
        
        if selectedExercises.contains(selectionChoices[indexPath.row]) {
            cell.label.font = Constant.components.exerciseTableCells.fontWhenSelected
            cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenSelected
        } else {
            cell.label.font = Constant.components.exerciseTableCells.fontWhenDeselected
            cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenDeselected
        }
    }
    
    fileprivate func configure(cell: PickerCell, at indexPath: IndexPath) {
        
        let exercise = selectionChoices[indexPath.row]
        
        if selectedExercises.contains(exercise) {
            cell.label.font = Constant.components.exerciseTableCells.fontWhenSelected
            cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenSelected
        } else {
            cell.label.font = Constant.components.exerciseTableCells.fontWhenDeselected
            cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenDeselected
        }
    }

    fileprivate func selectExercise( _ exerciseToSelect: Exercise) {
        guard let indexOfExercise = selectionChoices.index(of: exerciseToSelect) else {
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
        guard sender.state == .began else {
            return
        }
        
        let location = sender.location(in: table)
        if let indexPath = table.indexPathForRow(at: location) {
            let exerciseToEdit = selectionChoices[indexPath.row]
            let editor = ExerciseEditor(for: exerciseToEdit)
            editor.editorDataSource = self
            navigationController?.pushViewController(editor, animated: true)
        }
    }
    
    // MARK: Exit methods
    
    @objc func confirmAndDismiss() {
        exerciseReceiver?.receive(exercises: selectedExercises)
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
}

// MARK: - Extensions

// MARK: NewExerciseReceiver

extension ExercisePickerController: NewExerciseReceiver {
    
    func receiveNewExercise(_ exercise: Exercise) {
        selectionChoices.append(exercise)
        selectedExercises.append(exercise)
        table.reloadData()
        selectExercise(exercise)
    }
}

// MARK: TableView DataSource

extension ExercisePickerController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as! PickerCell
        configure(cell: cell, at: indexPath) // Makes previously selected, cells bold upon dequeuing
        cell.label.text = selectionChoices[indexPath.row].name
        cell.label.applyCustomAttributes(.more)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectionChoices.count
    }
}

// MARK: TableView Delegate

extension ExercisePickerController: UITableViewDelegate {

    /// Add/remove to selected and make it look selected/deselected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tappedExercise = selectionChoices[indexPath.row]
        // If already selected: remove og make look unselected
        if let index = selectedExercises.index(of: tappedExercise) {
            // deselect
            selectedExercises.remove(at: index)
            configure(cellAt: indexPath)
        } else {
            // select
            selectedExercises.append(tappedExercise)
            configure(cellAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.pickers.rowHeight
    }
}

// MARK: ExerciseEditorDataSource

protocol ExerciseEditorDataSource: AnyObject {
    func removeFromDataSource(exercise: Exercise)
}

extension ExercisePickerController: ExerciseEditorDataSource {

    func removeFromDataSource(exercise: Exercise) {
        // Deselect if selected
        if selectedExercises.contains(exercise) {
            if let indexOfExercise = selectedExercises.index(of: exercise) {
                selectedExercises.remove(at: indexOfExercise)
            }
        }
        // Remove from table and datasource
        if let index = selectionChoices.index(of: exercise) {
            let indexPath = IndexPath(row: index, section: 0)
            selectionChoices.remove(at: index)
            table.deleteRows(at: [indexPath], with: .fade)
        }
        
        table.reloadData()
    }
}

