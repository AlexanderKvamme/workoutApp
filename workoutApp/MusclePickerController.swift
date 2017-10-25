//
//  MusclePickerController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 22/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

// MARK: Class

class MusclePickerController: UIViewController {
    
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
    
    private lazy var plusButton: UIButton = {
        let image = UIImage(named: "plusButton")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        button.setImage(image, for: .normal)
        button.alpha = Constant.alpha.faded
        button.tintColor = UIColor.faded
        button.translatesAutoresizingMaskIntoConstraints = false
        //button.addTarget(self, action: #selector(presentNewExerciseController), for: .touchUpInside)
        
        return button
    }()
    
    // Properties
    
    var selectionChoices = [Muscle]()
    var selectedMuscles: [Muscle]! // used to refresh the picker after returning from making new exercise
    
    weak var exerciseReceiver: ExerciseReceiver?
    weak var muscleReceiver: MuscleReceiver?
    
    // MARK: - Initializers
    
    init(withPreselectedMuscles preselectedMuscles: [Muscle]?) {
        
        // Setup available choices
        self.selectedMuscles = preselectedMuscles
        self.selectionChoices = DatabaseFacade.fetchMuscles(with: .name, ascending: true)

        // Preselect
        if let preselections = preselectedMuscles {
            self.selectedMuscles = preselections
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        addSubViewsAndConstraints()
        view.backgroundColor = UIColor.light
        
        // Preselect
        for muscle in selectedMuscles {
            selectMuscle(muscle)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hidesBottomBarWhenPushed = true
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
        
        view.addSubview(header)
        view.addSubview(footer)
        view.addSubview(table)
//        view.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            // Footer
            footer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Header
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: Constant.components.headers.pickerHeader.topSpacing),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // + button
//            plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            plusButton.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
//            plusButton.heightAnchor.constraint(equalToConstant: 25),
//            plusButton.widthAnchor.constraint(equalToConstant: 25),
            
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
            drawDiagonalLineThroughTable()
        }
    }
    
    /// If contentView is smaller than the tableView. Add insets top and bottom to keep it centered.
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
    
    // MARK: Cell configuration methods
    
    /// Takes a indexpath, and makes it look selected or not depending on if its he of selected indexPaths
    fileprivate func configure(cellAt indexPath: IndexPath) {
        
        if let cell = table.cellForRow(at: indexPath) as? PickerCell {
            
            if selectedMuscles.contains(selectionChoices[indexPath.row]) {
                cell.label.font = Constant.components.exerciseTableCells.fontWhenSelected
                cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenSelected
            } else {
                cell.label.font = Constant.components.exerciseTableCells.fontWhenDeselected
                cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenDeselected
            }
        }
    }
    
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
        if let indexOfExercise = selectionChoices.index(of: muscleToSelect) {
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
            print("FIXME: - Implement muscle editor")
        default:
            break
        }
    }
    
    // MARK: Exit methods
    
    @objc func confirmAndDismiss() {
        
        print("confirming. gonna test count and then send back muscles")
        
        guard selectedMuscles.count > 0 else {
            navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
            print("failed")
            return
        }
        print("sending back: ", selectedMuscles)
        print("musclereceiver: ", muscleReceiver)
        muscleReceiver?.receive(muscles: selectedMuscles)
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
}

// MARK: - Extensions

// MARK: NewExerciseReceiver

extension MusclePickerController: NewExerciseReceiver {
    
    // FIXME: - Let user make new muscle?
    
    func receiveNewExercise(_ exercise: Exercise) {
//        selectionChoices.append(exercise)
//        selectedExercises.append(exercise)
//        table.reloadData()
//        selectExercise(exercise)
    }
}

// MARK: TableView DataSource

extension MusclePickerController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as! PickerCell
        
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
        return 30
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

