//
//  ExerciseTableViewCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreData

/*
 ExerciseTableViewCell is one cell in a table of exercises. So each cell represents one exercise, and contains any number of sets to be performed for the exercise.
 */

class ExerciseTableViewCell: ExerciseCell, hasNextCell, hasPreviousCell, UICollectionViewDataSource {

    private var plusButton: UIButton!
    private var verticalInsetForBox: CGFloat = 10
    private let collectionViewReuseIdentifier = "collectionViewCell"
    private var persistentContainer = NSPersistentContainer(name: Constant.coreData.name)
    
    // MARK: - Initializers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    init(withExerciseLog exerciseLog: ExerciseLog,
         lifts: [Lift],
         reuseIdentifier: String) {
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        setupBox()
        setupCell()
        setupPlusButton()
        setupCollectionView()
        setupConstraints()
        selectionStyle = .none
        
        // Log item to store each Lift in the current Exercise. This exercise is potentially sent to Core Data if user decides to store workout
        currentCellExerciseLog = DatabaseFacade.makeExerciseLog()
        liftsToDisplay = lifts
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func getIndexPath() -> IndexPath? {
        
        if let indexPath = owner.owner.tableView.indexPath(for: self) {
            return indexPath
        } else {
            print("ERROR: - Could not find indexPath")
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
    
    // MARK: - CollectionView delegate methods
    
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
        let newLift = DatabaseFacade.makeLift()
        newLift.datePerformed = Date() as NSDate
        newLift.reps = 0
        newLift.weight = 0
        newLift.owner = self.currentCellExerciseLog
        
        // add to dataSource and tableView
        liftsToDisplay.append(newLift)
        
        if let test = getIndexPath() {
            owner.totalLiftsToDisplay[test.section].append(newLift)
            owner.totalLiftsToDisplay[test.section].oneLinePrint()
            owner.exerciseLogsAsArray[test.section].addToLifts(newLift)
            
        } else {
            print(" no index path")
        }
        
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
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewReuseIdentifier, for: indexPath) as! ExerciseSetCollectionViewCell
        cell.owner = self
        
        let liftToDisplay = liftsToDisplay[indexPath.row]
        let repFromLift = liftToDisplay.reps
        cell.setReps(repFromLift)
        cell.isPerformed = liftToDisplay.hasBeenPerformed // is it already performed this workout and should be tappable?
        
        // Make bold if it is performed
        if liftsToDisplay[indexPath.row].hasBeenPerformed {
            cell.makeTextBold()
        }
        return cell
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

