//
//  ExerciseCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 18/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreData

 /// ExerciseCell is one cell in a table of exercises. So each cell represents one exercise, and contains any number of sets to be performed for the exercise. ExerciseCell can be either ExerciseCellForWorkout, or ExerciseCellForHistory

class ExerciseCellBaseClass: UITableViewCell {
    
    var exercise: Exercise!
    var currentCellExerciseLog: ExerciseLog!
    var liftsToDisplay: [Lift] = []
    var collectionView: UICollectionView!
    var box: ExerciseTableCellBox!
    var verticalInsetForBox: CGFloat = 10
    
    weak var owner: ExerciseTableDataSource?
    
    // Optional Properties
    var plusButton: UIButton?
    
    // MARK: Initializers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .akLight
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol LiftCellManager {}

extension LiftCellManager where Self: ExerciseCellBaseClass, Self: UICollectionViewDataSource {
    
    func setupCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let leftInset: CGFloat = 10
        
        let collectionViewFrame = CGRect(x: box.boxFrame.frame.minX + Constant.components.box.shimmerInset + leftInset, y: box.boxFrame.frame.minY + verticalInsetForBox, width: box.boxFrame.frame.width - 2*Constant.components.box.shimmerInset - leftInset, height: box.boxFrame.frame.height)
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        
        collectionView.register(UnweightedLiftCell.self, forCellWithReuseIdentifier: CellID.unweighted)
        collectionView.register(WeightedLiftCell.self, forCellWithReuseIdentifier: CellID.weighted)
        
        collectionView.alpha = 1
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        
        let plusButtonWidth: CGFloat = plusButton?.frame.width ?? 0
        collectionView.frame.size = CGSize(width: collectionView.frame.width - plusButtonWidth, height: collectionView.frame.height)
    }
    
    func setupBox(forExercise exercise: Exercise) {
        var boxFactory: BoxFactory!
        
        switch exercise.isWeighted() {
        case true:
            boxFactory = BoxFactory.makeFactory(type: .TallExerciseTableCellBox)
        case false:
            boxFactory = BoxFactory.makeFactory(type: .ExerciseTableCellBox)
        }
        
        let boxHeader = boxFactory.makeBoxHeader()
        let boxSubHeader = boxFactory.makeBoxSubHeader()
        let boxFrame = boxFactory.makeBoxFrame()
        let boxContent = boxFactory.makeBoxContent()
        
        switch exercise.isWeighted(){
        case true:
            box = TallExerciseTableCellBox(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent)
        case false:
            box = ShortExerciseTableCellBox(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent)
        }
        
        contentView.addSubview(box)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Conformance

extension ExerciseCellBaseClass: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getSize(for: indexPath)
    }
    
    /// Calculates size of liftCell efficiently without using autolayout
    private func getSize(for indexPath: IndexPath) -> CGSize {
        // check dataSource if weighted or not
        let isWeighted = liftsToDisplay[indexPath.row].isWeighted()
        typealias cellSizes = Constant.components.collectionViewCells
        
        switch isWeighted {
        case true:
            return CGSize(width: cellSizes.width, height: cellSizes.weightedHeight)
        case false:
            return CGSize(width: cellSizes.width, height: cellSizes.unweightedHeight)
        }
    }
}

// MARK: Make Longpressable

extension ExerciseCellBaseClass {
    
    func addLongpressRecognizer() {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView.addGestureRecognizer(lpgr)
    }
    
    @objc func handleLongPress(_ gestureReconizer: UILongPressGestureRecognizer) {
        preconditionFailure("handle longpress in subclass")
    }
}

// MARK: - ExerciceCell For Workout

class ExerciseCellForWorkouts: ExerciseCellBaseClass, LiftCellManager, hasNextCell {

    // MARK: Properties
    
    var activeLiftCell: LiftCell?
    
    // MARK: Initializer
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    init(withExerciseLog exerciseLog: ExerciseLog, lifts: [Lift], reuseIdentifier: String) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.exercise = exerciseLog.getDesign()
        
        setupBox(forExercise: exercise)
        setupPlusButton()
        setupCollectionView()
        setupConstraints()
        selectionStyle = .none
        
        currentCellExerciseLog = DatabaseFacade.makeExerciseLog()
        liftsToDisplay = lifts
        addLongpressRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleTap(on ip: IndexPath) {
        print("tapped on ", ip)
        
        guard let cell = self.collectionView(self.collectionView, cellForItemAt: ip) as? LiftCell else {
            fatalError()
        }
        
        switch cell.isPerformed {
        case true:
            cell.focus()
        case false:
            if let firstUnperformedCell = getFirstFreeCell() {
                firstUnperformedCell.forceFocus()
            } else {
                insertNewCell()
            }
        }
    }
    
    // MARK: Delegate Methods
    
    func liftCellTapHandler(at indexPath: IndexPath) {
        print("received tap in ExerciseCell, from LiftCell: ", indexPath)
    }
    
    // MARK: Methods
    
    @objc func plusButtonHandler() {
        nextOrNewLiftCell()
    }
    
    func nextOrNewLiftCell() {
        let firstFreeCell = getFirstFreeCell()
        if firstFreeCell == nil {
            insertNewCell()
        } else {
            firstFreeCell!.focus()
        }
    }
    
    func getFirstFreeCell() -> LiftCell? {
        // use getNextCell until it has no other nextCell, return this last cell
        guard let firstCell = getFirstCell() else {
            return nil
        }
        
        var currentCell = firstCell
        
        if currentCell.isPerformed == false {
            return currentCell
        }
        
        while let nextCell = currentCell.getNextCell() {
            currentCell = nextCell
            if currentCell.isPerformed == false {
                return currentCell
            }
        }
        return nil
    }
    
    private func getFirstCell() -> LiftCell? {
        let ip = IndexPath(row: 0, section: 0)
        if let firstCell = collectionView.cellForItem(at: ip) as? LiftCell {
            return firstCell
        } else {
            return nil
        }
    }
    
    private func getIndexPath() -> IndexPath? {
        guard let indexPath = owner?.owner.tableView.indexPath(for: self) else { return nil }
        
        return indexPath
    }
    
    private func insertNewCell() {
        // make new lift value to be displayed
        let newLift = DatabaseFacade.makeLift()
        newLift.owner = self.currentCellExerciseLog
        newLift.datePerformed = Date() as NSDate
        newLift.weight = 0
        newLift.reps = 0
        
        // add to dataSource and tableView
        liftsToDisplay.append(newLift)
        
        if let ip = getIndexPath() {
            owner?.totalLiftsToDisplay[ip.section].append(newLift)
            owner?.exerciseLogsAsArray[ip.section].addToLifts(newLift)
        }
        
        // Make it selected and show keyboard
        let itemCount = collectionView.numberOfItems(inSection: 0)
        let newIndexPath = IndexPath(item: itemCount, section: 0)
        collectionView.insertItems(at: [newIndexPath])
        collectionView.scrollToItem(at: newIndexPath, at: .right, animated: false)
        
        if let cell = self.collectionView.cellForItem(at: newIndexPath) as? LiftCell {
            cell.focus()
        }
    }
    
    // Setup methods
    
    private func setupPlusButton() {
        let shimmerHeight = box.boxFrame.shimmer.frame.height
        plusButton = UIButton(frame: CGRect(x: 0, y: 0, width: shimmerHeight, height: shimmerHeight))
        let plusButtonBackground = UIView()
        plusButtonBackground.layer.cornerRadius = 14
        plusButtonBackground.backgroundColor = .akDark
        
        guard let plusButton = plusButton else { return }
        
        let img = UIImage.close24.withTintColor(.akLight).rotate(radians: .pi/4)
        plusButton.setImage(img, for: .normal)
        plusButton.accessibilityIdentifier = "cell-plus-button"
        plusButton.addTarget(self, action: #selector(plusButtonHandler), for: .touchUpInside)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.imageView?.contentMode = .scaleAspectFit
        
        // Layout
        contentView.addSubview(plusButtonBackground)
        contentView.addSubview(plusButton)
        
        if exercise.isWeighted() {
            plusButtonBackground.snp.makeConstraints { make in
                make.centerY.equalTo(box.boxFrame)
                make.right.equalTo(box.boxFrame).inset(8)
                make.width.equalTo(36)
                make.height.equalTo(36)
            }
        } else {
            plusButtonBackground.snp.makeConstraints { make in
                make.top.right.bottom.equalTo(box.boxFrame).inset(8)
                make.width.height.equalTo(36)
            }
        }
        
        plusButton.snp.makeConstraints { make in
            make.edges.equalTo(plusButtonBackground).inset(8)
            plusButton.imageView?.contentMode = .scaleAspectFit
        }
        
        setNeedsLayout()
    }
    
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        box.translatesAutoresizingMaskIntoConstraints = false
        
        // contentView
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: box.topAnchor, constant: -verticalInsetForBox),
            contentView.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: verticalInsetForBox),
            contentView.widthAnchor.constraint(equalToConstant: Constant.UI.width),
            ])
        
        // The box
        NSLayoutConstraint.activate([
            box.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            box.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            box.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: 0),
            ])
    }
}

extension ExerciseCellForWorkouts {
    
    override func handleLongPress(_ gestureReconizer: UILongPressGestureRecognizer) {
        guard gestureReconizer.state == UIGestureRecognizerState.began else {
            return
        }
        
        // Get longpressed indexPath
        let point = gestureReconizer.location(in: collectionView)
        guard let ip = collectionView.indexPathForItem(at: point) else {
            return
        }

        liftsToDisplay.remove(at: ip.row)
        collectionView.deleteItems(at: [ip])
        
        if let section = owner?.owner.tableView.indexPath(for: self)?.section {
            
            let liftToRemove = owner?.totalLiftsToDisplay[section][ip.row]
            owner?.totalLiftsToDisplay[section].remove(at: ip.row)
            
            DatabaseFacade.delete(liftToRemove!)
        }
    }
}

// MARK: ExerciseCellForWorkouts - UITextFieldDelegate

extension ExerciseCellForWorkouts: UITextFieldDelegate {
    
    // MARK: - TextField Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        guard let activeLiftCell = activeLiftCell else {
            preconditionFailure("Field should be assosciated with a cell")
        }

        owner?.owner.activeTableCell = self
        activeLiftCell.setPlaceholderVisuals(textField)
        
        NotificationCenter.default.addObserver(self, selector: #selector(nextButtonTapHandler), name: Notification.Name.keyboardsNextButtonDidPress, object: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Make sure input is convertable to an integer for Core Data
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeLiftCell?.validateFields()
        NotificationCenter.default.removeObserver(self, name: .keyboardsNextButtonDidPress, object: nil)
    }
    
    // MARK: Clean this
    
    @objc func nextButtonTapHandler() {
        // Make sure cell nextable
        guard let activeLiftCell = activeLiftCell as? NextableLift else {
            preconditionFailure("Was not nextable")
        }
        // Let cell handle
        activeLiftCell.NextHandler()
    }
}

// MARK: ExerciseCellForWorkouts - UICollectionViewDataSource

extension ExerciseCellForWorkouts: UICollectionViewDataSource {
    
    // numberOfItemsInSection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return liftsToDisplay.count
    }
    
    // cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let liftToDisplay = liftsToDisplay[indexPath.row]
        
        var cell: LiftCell!
        
        if self.exercise.isWeighted() {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID.weighted, for: indexPath) as! WeightedLiftCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID.unweighted, for: indexPath) as! UnweightedLiftCell
        }
        
        cell.superTableCell = self
        
        let liftIsPerformed = liftToDisplay.hasBeenPerformed
        
        let repFromLift = liftToDisplay.reps
        cell.setReps(repFromLift)
        cell.isPerformed = liftIsPerformed
        
        if let c = cell as? WeightedLiftCell {
            c.setWeight(liftToDisplay.weight)
            if liftIsPerformed {
                c.makeWeightTextBold()
            }
        }
        // Make bold if it is performed
        if liftIsPerformed {
            cell.setInputtedStyle()
        }
        return cell
    }
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
