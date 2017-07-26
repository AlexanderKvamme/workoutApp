//
//  ExerciseTableViewCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

/*
 ExerciseTableViewCell is one cell in a table of exercises. So each cell represents one exercise, and contains any number of sets to be performed for the exercise.
 */

class ExerciseTableViewCell: UITableViewCell, hasNextCell, hasPreviousCell, UICollectionViewDelegate, UICollectionViewDataSource {

    private let collectionViewReuseIdentifier = "collectionViewCell"
    var liftsToDisplay: [Lift]!
    var collectionView: UICollectionView!
    private var plusButton: UIButton!
    var box: Box!
    private var verticalInsetForBox: CGFloat = 10
    var currentCellExerciseLog: ExerciseLog! // each cell in this item, displays the Exercise, and all the LiftLog items are contained by a ExerciseLog item.
    
    weak var owner: ExerciseTableViewDataSource!
    
    // MARK: - Initializers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupBox()
        setupConstraints()
        selectionStyle = .none
        
        // Log item to store each Lift in the current Exercise. This exercise is potentially sent to Core Data if user decides to store workout
        currentCellExerciseLog = DatabaseController.createManagedObjectForEntity(.ExerciseLog) as! ExerciseLog
    }
    
    // Initialize cell by injecting an Exercise
    convenience init(withExerciseLog exerciseLog: ExerciseLog, andIdentifier cellIdentifier: String?) {
        self.init(style: .default, reuseIdentifier: cellIdentifier)
        
        // Uses injected Exercise to fetch the latest ExerciseLog of that Exercise type.
        
        setupCell()
        setupPlusButton()
        setupCollectionView()
        
        // For this tableViewCell, retrieve the latest exerciseLog for this exercise, and use the newest logged exercise to display in the collectionviewcells
        
        // the cells will display one exercises last ExerciseLog, sorted by time performed. So each cell gets n Lifts, ordered in an array
        
        let lifts = exerciseLog.lifts as! Set<Lift>
        
        // make sortingFunction
        func backwards(s1: Lift, s2: Lift) -> Bool {
            if let date1 = s1.datePerformed, let date2 = s2.datePerformed {
                return date1 as Date > date2 as Date
            }
            return false
        }
        
        // Sort
        let sortedLifts = lifts.sorted(by: backwards)
        liftsToDisplay = sortedLifts // update dataSource
//        owner.totalLiftsToDisplay[
        
        // FIXME: - set up initial index of totalLiftsToDisplay?

        // tror ikke jeg kan aksessere owner.totalLift fordi total er ikke satt i initializeren.
        
//        if let ip = getIndexPath() {
//            owner.totalLiftsToDisplay[ip.section] = liftsToDisplay
//        }
        
        // testprint
        print()
        for l in liftsToDisplay {
            print(l.reps)
        }
    }
    
    
    // Initialize cell by injecting an Exercise
    convenience init(withExercise exercise: Exercise, andIdentifier cellIdentifier: String?) {
        self.init(style: .default, reuseIdentifier: cellIdentifier)

        setupCell()
        setupPlusButton()
        setupCollectionView()
        
        // For this tableViewCell, retrieve the latest exerciseLog for this exercise, and use the newest logged exercise to display in the collectionviewcells
        
        let exerciseLogs = exercise.loggedInstances as! Set<ExerciseLog>
        
        // the cells will display one exercises last ExerciseLog, sorted by time performed. So each cell gets n Lift's, ordered in an array
        for log in exerciseLogs {
            for _ in log.lifts as! Set<Lift> {
                let sortDescriptor: [NSSortDescriptor] = [NSSortDescriptor(key: "datePerformed", ascending: false)]
                let sortedLifts = log.lifts?.sortedArray(using: sortDescriptor) as! [Lift]
                liftsToDisplay = sortedLifts // dataSource update with
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Data source update
    
    func updateDataSourceWIP() {
        // should update the ExerciseTableViewDataSource... it has an array of liftsToDisplay: [Lift], so that it is in fact [[Lift]], this cells [Lift] should be accessable by using this cells section/row, and whenever this method is called, it should update the this [[Lift]] to keep it ready for a possible save
        
        // FIXME: - PSEUDO
        
        // - get this cells indexPath
        // - test until that its the correct one
        // - update the correct index
        
        // - get this cells indexPath
        if let indexPath = getIndexPath() {
            print("ip: ", indexPath)
            print("row: ", indexPath.row)
            owner.totalLiftsToDisplay[indexPath.section] = liftsToDisplay
        
            print("updated the row to ", owner.totalLiftsToDisplay[indexPath.section])
            
            // problem could be that its not properly initialized, that i need to initialize it empty when making the workoutLog
            
            
        } else {
            print(" nah bro i couldnt find")
        }
        
        // - test until that its the correct one
        
    }
    
    // MARK: - Helpers
    
    private func getIndexPath() -> IndexPath? {
        if let indexPath = owner.owner.tableView.indexPath(for: self) {
            print("ip: ", indexPath)
            return indexPath
        } else {
            print(" nah bro i couldnt find")
        }
        return nil
    }
    
    private func setupPlusButton() {
        let shimmerHeight = box.boxFrame.shimmer.frame.height
        plusButton = UIButton(frame: CGRect(x: 0, y: 0, width: shimmerHeight, height: shimmerHeight))
        plusButton.setTitle("+", for: .normal)
        plusButton.setTitleColor(.light, for: .normal)
        plusButton.titleLabel?.font = UIFont.custom(style: .bold, ofSize: .bigger)
        plusButton.addTarget(self, action: #selector(plusButtonHandler), for: .touchUpInside)
        
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout
        contentView.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: box.boxFrame.topAnchor),
            plusButton.bottomAnchor.constraint(equalTo: box.boxFrame.bottomAnchor),
            plusButton.rightAnchor.constraint(equalTo: box.boxFrame.rightAnchor),
            plusButton.centerYAnchor.constraint(equalTo: box.boxFrame.centerYAnchor),
            plusButton.widthAnchor.constraint(equalTo: plusButton.heightAnchor),
            ])
        setNeedsLayout()
    }
    
    func plusButtonHandler() {
        // select either first cell that isnt set, or make and select a new one
        let firstFreeCell = getFirstFreeCell()
        if firstFreeCell == nil {
            insertNewCell()
        } else {
            firstFreeCell!.tapHandler()
        }
    }
    
    func setDebugColors() {
        // collectionView
        self.collectionView.backgroundColor = .green
        self.collectionView.alpha = 0.5
        
        // + button
        plusButton.backgroundColor = .red
        plusButton.titleLabel?.backgroundColor = .yellow
    }
    
    // MARK: - CollectionView delegate methods
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewReuseIdentifier, for: indexPath) as! ExerciseSetCollectionViewCell
        cell.owner = self
        
        let repFromLift = liftsToDisplay[indexPath.row].reps
        cell.setReps(repFromLift)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("did select some item at indexpath \(indexPath)")
    }
    
    func getFirstFreeCell() -> ExerciseSetCollectionViewCell? {
        // use getNextCell until it has no other nextCell, return this last cell
        guard let firstCell = getFirstCell() else { return nil }
        
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
    
    func getFirstCell() -> ExerciseSetCollectionViewCell? {
        let ip = IndexPath(row: 0, section: 0)
        if let firstCell = collectionView.cellForItem(at: ip) as? ExerciseSetCollectionViewCell {
            return firstCell
        } else {
            return nil
        }
    }
    
    func insertNewCell() {
        let itemCount = collectionView.numberOfItems(inSection: 0)
        
        // make new lift value to be displayed
        let newLift = DatabaseController.createManagedObjectForEntity(.Lift) as! Lift
        newLift.datePerformed = Date() as NSDate
        newLift.reps = 0
        newLift.weight = 0
        newLift.owner = self.currentCellExerciseLog
        
        // add to dataSource and tableView
        liftsToDisplay.append(newLift)
        let newIndexPath = IndexPath(item: itemCount, section: 0)
        collectionView.insertItems(at: [newIndexPath]) // needs to have a matching Lift in the dataSource array
        
        // Make it selected and show keyboard
        UIView.animate(withDuration: 0.5,
                       animations: { 
                        self.collectionView.scrollToItem(at: newIndexPath, at: .right, animated: false)
        }) { _ in
            if let c = self.collectionView.cellForItem(at: newIndexPath) as? ExerciseSetCollectionViewCell {
            self.collectionView.selectItem(at: newIndexPath, animated: false, scrollPosition: .centeredHorizontally)
                c.tapHandler()
            }
        }
    }
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return liftsToDisplay.count
    }
    
    // MARK: - setup methods
    
    private func setupCollectionView() {
        
        // CollectionView
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionViewFrame = CGRect(x: box.boxFrame.frame.minX + Constant.components.Box.shimmerInset,
                                         y: box.boxFrame.frame.minY + verticalInsetForBox,
                                         width: box.boxFrame.frame.width - 2*Constant.components.Box.shimmerInset,
                                         height: box.boxFrame.frame.height)
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        collectionView.register(ExerciseSetCollectionViewCell.self, forCellWithReuseIdentifier: collectionViewReuseIdentifier)
        collectionView.alpha = 1
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        
        collectionView.frame.size = CGSize(width: collectionView.frame.width - plusButton.frame.width,
                                           height: collectionView.frame.height)
    }
    
    private func setupCell() {
        backgroundColor = .light
    }
    
    private func setupBox() {
        let boxFactory = BoxFactory.makeFactory(type: .ExerciseProgressBox)
        let boxHeader = boxFactory.makeBoxHeader()
        let boxSubHeader = boxFactory.makeBoxSubHeader()
        let boxFrame = boxFactory.makeBoxFrame()
        let boxContent = boxFactory.makeBoxContent()
        
        box = Box(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent)
        
        contentView.addSubview(box)
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
        
        // the box
        NSLayoutConstraint.activate([
            box.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            box.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            box.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: 0),
            ])
    }
}

