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
    
    private lazy var table: UITableView = {
        
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
    var selectedIndexPaths = [IndexPath]()
    var selectionChoices = [Exercise]()
    var selectedMuscle: Muscle! // used to refresh the picker after returning from making new exercise
    
    // Delegates
    weak var exerciseReceiver: isExerciseReceiver?
    weak var pickableReceiver: PickableReceiver?
    
    // MARK: - Initializers
    
    init(forMuscle muscle: Muscle, withPreselectedExercises preselectedExercises: [Exercise]?) {
        
        // Setup avaiable choices
        self.selectedMuscle = muscle
        selectionChoices = DatabaseFacade.fetchExercises(usingMuscle: muscle)!
      
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
        addSubViewAndConstraints()
        
        // Preselect
        for exercise in selectedExercises {
            selectExercise(exercise)
        }
    
        table.reloadData()
        view.setNeedsLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hidesBottomBarWhenPushed = true
        addLongPressGestureRecognizer()
        table.reloadData()
    }
    
    // MARK: - Methods
    
    func addSubViewAndConstraints() {
        
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
        
        table.layoutIfNeeded() // Update Content
        
        // disable scrolling if all content fits in the frame
        let tableHeight = table.frame.height
        let contentHeight = table.contentSize.height
        
        // Refactor the rest to another place and animate recicing
        if contentHeight > tableHeight {
            table.isScrollEnabled = true
        } else {
            table.isScrollEnabled = false
            drawDiagonalLineThroughTable()
        }
        
        view.backgroundColor = UIColor.light
        
        table.reloadData()
    }
    
    func setHeaderTitle(_ newTitle: String) {
        header.topLabel.text = newTitle
    }
    
    func dismissView() {
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
    
    // MARK: Delegate methods
    
    func receiveNewExercise(_ exercise: Exercise) {
        selectionChoices.append(exercise)
        selectedExercises.append(exercise)
        selectExercise(exercise)
    }
    
    // Editor data source
    
    func removeFromDataSource(exercise: Exercise) {
    
        print("\n pre removal")
        print("selectedExercises: ", selectedExercises)
        print("selectedIndexPaths: ", selectedIndexPaths)
        
        print("selectedExercises count: ", selectedExercises.count)
        print("selectedIndexPaths count: ", selectedIndexPaths.count)
        
        // Deselect if selected
        if selectedExercises.contains(exercise) {
            if let indexOfExercise = selectedExercises.index(of: exercise) {
                selectedIndexPaths.remove(at: indexOfExercise)
                selectedExercises.remove(at: indexOfExercise)
            } else {
                print("exercise to delete was not selected")
            }
            
            print("\n AFTER removal")
            print("selectedExercises: ", selectedExercises)
            print("selectedIndexPaths: ", selectedIndexPaths)
            
            print("selectedExercises count: ", selectedExercises.count)
            print("selectedIndexPaths count: ", selectedIndexPaths.count)
        }
        
        // Remove from table and datasource
        if selectionChoices.contains(exercise) {
            if let index = selectionChoices.index(of: exercise) {
                let indexPath = IndexPath(row: index, section: 0)
                selectionChoices.remove(at: index)
                table.deleteRows(at: [indexPath], with: .fade)
            }
        } else {
            print(" selectionchoices did NOT contain it")
        }
    }

    // MARK: Helper methods
    
    func addNewExerciseButton() {
        let width: CGFloat = 25
        
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
            button.heightAnchor.constraint(equalToConstant: width),
            button.widthAnchor.constraint(equalToConstant: width),
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
    
    // MARK: Tableview Delegate Methods
    
    /// Takes a cell, and makes it look selected or not depending on if its located in the cache of selected indexPaths
    func configure(_ cell: PickerCell, forIndexPath indexPath: IndexPath) {
        if selectedIndexPaths.contains(indexPath) {
            
            cell.label.font = Constant.components.exerciseTableCells.fontWhenSelected
            cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenSelected
        } else {
            cell.label.font = Constant.components.exerciseTableCells.fontWhenDeselected
            cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenDeselected
        }
    }
    
    private func selectExercise( _ exerciseToSelect: Exercise) {
        
        // FIXME: - Noe feil med denne når den kalles fra vda
        print("tryna select")
        if let indexOfExercise = selectionChoices.index(of: exerciseToSelect) {
            let indexPath = IndexPath(row: indexOfExercise, section: 0)
            table.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            selectedIndexPaths.append(indexPath)
        }
    }
    
    // Count selected rows to return to NewWorkoutViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if tapped indexPath is already contained, remove from cache and unselect it
        if selectedIndexPaths.contains(indexPath){
            // deselect
            if let indexOfExercise = selectedIndexPaths.index(of: indexPath){
                selectedIndexPaths.remove(at: indexOfExercise)
                 selectedExercises.remove(at: indexOfExercise)
                
                // FIXME: hvorfor klikker den her? - tror det er fordi at indexpathen ikke fjernes på delete... Eller kanskje den fjernes... men alle indexpathsene blir 1 off... fordi om du har 10 og alle er selected, og du fjerner [5], så er ikke tableRowsene på 5-9 rett lenger...
            }
            if let indexOfIndexPath = selectedIndexPaths.index(of: indexPath) {
                print(" found it at \(indexOfIndexPath)")
                selectedIndexPaths.remove(at: indexOfIndexPath)
            }
        } else {
            print(" not yet contained in arrays, so adding")
            // exercise is not yet contained in the array, so append and make it look selected
            selectedIndexPaths.append(indexPath)
            selectedExercises.append(selectionChoices[indexPath.row])
        }
        
        // configure to look selected/deselected
        let selectedCell = tableView.cellForRow(at: indexPath)! as! PickerCell
        configure(selectedCell, forIndexPath: indexPath)
        
        print("\n\n AFTER didSelectRowAt: ", indexPath)
        print("selectedExercises: ", selectedExercises)
        print("selectedIndexPaths: ", selectedIndexPaths)
        
        print("selectedExercises count: ", selectedExercises.count)
        print("selectedIndexPaths count: ", selectedIndexPaths.count)
    }
    
    private func drawDiagonalLineThroughTable() {
        let v = UIView(frame: table.frame)
        v.frame.size = CGSize(width: v.frame.height - 200, height:  v.frame.width - 200)
        v.center.y = table.center.y + 75
        v.center.x = table.center.x
        drawDiagonalLineThrough(v, inView: view)
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
        exerciseReceiver?.receive(selectedExercises)
        
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
}

// MARK: - Extensions

// MARK: NewExerciseReceiver

extension ExercisePickerController: NewExerciseReceiver {}

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
        configure(cell, forIndexPath: indexPath)
        cell.label.text = selectionChoices[indexPath.row].name
        cell.label.applyCustomAttributes(.more)
        cell.sizeToFit()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectionChoices.count
    }
}

extension ExercisePickerController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
}

