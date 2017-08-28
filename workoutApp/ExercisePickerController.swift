//
//  WorkoutPickerViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 26/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

// MARK: ExerciseEditorDataSource

protocol ExerciseEditorDataSource: class {
    func removeFromDataSource(exercise: Exercise)
}

// MARK: Class

class ExercisePickerController: UIViewController, ExerciseEditorDataSource {
    
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
        
        view.cancelButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        view.approveButton.addTarget(self, action: #selector(confirmAndDismiss), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var header: TwoLabelStack = {
        let headerLabel = PickerHeader(text: "SELECT")
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return headerLabel
    }()
    
    let cellIdentifier = "cellIdentifier"
    var selectedExercises = [Exercise]()
    var selectionChoices = [Exercise]()
    var selectedMuscle: Muscle! // used to refresh the picker after returning from making new exercise
    
    // Delegates
    weak var exerciseReceiver: ExerciseReceiver?
    weak var pickableReceiver: PickableReceiver?
    
    // MARK: - Initializers
    
    init(forMuscle muscle: Muscle, withPreselectedExercises preselectedExercises: [Exercise]?) {
        
        // Setup avaiable choices
        self.selectedMuscle = muscle
        
        let exercises = DatabaseFacade.fetchExercises(usingMuscle: muscle)!
        let orderedExercises = exercises.sorted(by: { (a, b) -> Bool in
            guard let ac = a.name?.characters.first, let bc = b.name?.characters.first else {
                return false
            }
            return ac < bc
        })
        
        selectionChoices = orderedExercises
      
        // Preselect
        if let preselections = preselectedExercises {
            self.selectedExercises = preselections
        }
        
        super.init(nibName: nil, bundle: nil)
        addNewExerciseButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        addSubViewsAndConstraints()
        
        // Preselect
        for exercise in selectedExercises {
            selectExercise(exercise)
        }
    
        table.reloadData()
        view.setNeedsLayout()
        
        print(table.frame)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hidesBottomBarWhenPushed = true
        addLongPressGestureRecognizer()
        table.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {

        UIView.animate(withDuration: 0.5) {
            self.updateScrollingAndInsets()
        }
    }
    
    // MARK: - Methods
    
    func addSubViewsAndConstraints() {
        
        view.addSubview(header)
        view.addSubview(footer)
        view.addSubview(table)
        
        NSLayoutConstraint.activate([
            
            // Footer
            footer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Header
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Table
            table.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 100),
            table.bottomAnchor.constraint(equalTo: footer.topAnchor, constant: -100),
            table.leftAnchor.constraint(equalTo: view.leftAnchor),
            table.rightAnchor.constraint(equalTo: view.rightAnchor),
            ])
        
        updateScrollingAndInsets()
        
        view.backgroundColor = UIColor.light
    }
    
    func setHeaderTitle(_ newTitle: String) {
        header.topLabel.text = newTitle
    }
    
    func dismissView() {
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
    
    // MARK: Delegate methods
    
    // FIXME: - TEST INSETS
    
    private func updateScrollingAndInsets() {
        
        table.layoutIfNeeded() // Update Content
        table.reloadData()
        
        // disable scrolling if all content fits in the frame
        let tableHeight = table.frame.height
        let contentHeight = table.contentSize.height
        
        // Refactor the rest to another place and animate resizing
        if contentHeight > tableHeight {
            table.isScrollEnabled = true
            setTableInsets()
        } else {
            table.isScrollEnabled = false
            setTableInsets()
            drawDiagonalLineThroughTable()
        }
    }
    
    private func setTableInsets() {
        let tableHeight = table.frame.height
        let contentHeight = table.contentSize.height
        
        if tableHeight > contentHeight {
            // make insets
            let difference = tableHeight-contentHeight
            table.contentInset = UIEdgeInsets(top: difference/2, left: 0, bottom: difference/2, right: 0)
        } else {
            table.contentInset = UIEdgeInsets.zero
        }
    }
    
    
    // Editor data source
    
    func removeFromDataSource(exercise: Exercise) {
    
        for e in selectedExercises {
            print(e.name!)
        }
        
        // Deselect if selected
        if selectedExercises.contains(exercise) {
            if let indexOfExercise = selectedExercises.index(of: exercise) {
                selectedExercises.remove(at: indexOfExercise)
            }
            
            for e in selectedExercises {
                print(e.name!)
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

    // MARK: Helper methods
    
    func addNewExerciseButton() {
        
        let img = UIImage(named: "newButton")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        button.tintColor = UIColor.faded
        button.alpha = Constant.alpha.faded
        button.setImage(img, for: .normal)
        view.addSubview(button)
        
        // Layout
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
            button.heightAnchor.constraint(equalToConstant: 25),
            button.widthAnchor.constraint(equalToConstant: 25),
            ])
        
        // On tap: present newExerciseController
        button.addTarget(self, action: #selector(newExerciseTapHandler), for: .touchUpInside)
    }
    
    @objc private func newExerciseTapHandler() {
    
        let newExerciseController = NewExerciseController(withPreselectedMuscle: selectedMuscle)
        newExerciseController.exercisePickerDelegate = self
        
        // Make presentable outside of navigationController, used for testing
        if let navigationController = navigationController {
            navigationController.pushViewController(newExerciseController, animated: Constant.Animation.pickerVCsShouldAnimateIn)
        } else {
            present(newExerciseController, animated: Constant.Animation.pickerVCsShouldAnimateIn, completion: nil)
        }
    }
    
    // MARK: Cell configuration
    
    /// Takes a indexpath, and makes it look selected or not depending on if its he of selected indexPaths
    fileprivate func configure(cellAt indexPath: IndexPath) {

        if let cell = table.cellForRow(at: indexPath) as? PickerCell {
        
            if selectedExercises.contains(selectionChoices[indexPath.row]) {
                cell.label.font = Constant.components.exerciseTableCells.fontWhenSelected
                cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenSelected
            } else {
                cell.label.font = Constant.components.exerciseTableCells.fontWhenDeselected
                cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenDeselected
            }
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
        if let indexOfExercise = selectionChoices.index(of: exerciseToSelect) {
            let indexPath = IndexPath(row: indexOfExercise, section: 0)
            table.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            configure(cellAt: indexPath)
        }
    }
    
    private func drawDiagonalLineThroughTable() {
        
        let shrinkBy: CGFloat = 50
    
        // set up size. Draw later
        let p1 = CGPoint(x: 0, y: table.frame.height - 2*shrinkBy)
        let p2 = CGPoint(x: table.frame.width - 2*shrinkBy, y: 0)
        
        let path = UIBezierPath()
        path.move(to: p1)
        path.addLine(to: p2)

        let lineWidth = path.bounds.width
        let lineHeight = path.bounds.height

        let shapeLayer = CAShapeLayer()
        shapeLayer.frame.size = CGSize(width: lineWidth, height: lineHeight)
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.primary.cgColor
        shapeLayer.lineCap = "round"
        shapeLayer.lineWidth = 3.0
      
        let lineView = UIView()
        lineView.clipsToBounds = true // makes diagonalLine animate in when deleting and
        lineView.frame.size = CGSize(width: lineWidth, height: lineHeight)
        lineView.layer.addSublayer(shapeLayer)
        
        view.addSubview(lineView)
        view.sendSubview(toBack: lineView)
        
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lineView.centerXAnchor.constraint(equalTo: table.centerXAnchor),
            lineView.centerYAnchor.constraint(equalTo: table.centerYAnchor),
            lineView.heightAnchor.constraint(equalToConstant: lineHeight),
            lineView.widthAnchor.constraint(equalToConstant: lineWidth),
            ])
        
        lineView.frame.size = CGSize(width: lineWidth, height: lineHeight)
    }
    
    // MARK: Gesture recognizer methods
    
    private func addLongPressGestureRecognizer() {
        let longpressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        table.addGestureRecognizer(longpressGR)
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            let location = sender.location(in: table)
            if let indexPath = table.indexPathForRow(at: location) {
                let exerciseToEdit = selectionChoices[indexPath.row]
                let editor = ExerciseEditor(for: exerciseToEdit)
                editor.editorDataSource = self
                navigationController?.pushViewController(editor, animated: true)
            }
        default:
            break
        }
    }
    
    // MARK: Exit methods
    
    func confirmAndDismiss() {
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

// MARK: PickableReceiver

extension ExercisePickerController: PickableReceiver {
    func receivePickable(_ pickable: PickableEntity) {
        print(" should receive: ", pickable)
    }
}

// MARK: PickableSender

extension ExercisePickerController: PickableSender {
    func sendBack(pickable: Exercise) {
        print("would send back pickable: ", pickable)
    }

    typealias Pickable = Exercise

//    weak var pickableReceiver: PickableReceiver? {
//        get { return self.pickableReceiver }
//        set { self.pickableReceiver = newValue }
//    }
}

// MARK: TableView DataSource

extension ExercisePickerController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PickerCell
        
        configure(cell: cell, at: indexPath)
        cell.label.text = selectionChoices[indexPath.row].name
        cell.label.applyCustomAttributes(.more)
        cell.sizeToFit()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectionChoices.count
    }
}

// MARK: TableView Delegate

extension ExercisePickerController: UITableViewDelegate {

    // Add/remove to selected and make it look selected/deselected
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
        return 30
    }
}

