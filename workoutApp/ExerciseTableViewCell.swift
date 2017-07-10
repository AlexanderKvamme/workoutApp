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

protocol hasNextCell: class {
    func getNextCell(fromIndexPath: IndexPath) -> ExerciseSetCollectionViewCell
}

class ExerciseTableViewCell: UITableViewCell, hasNextCell, UICollectionViewDelegate, UICollectionViewDataSource {

    private let collectionViewReuseIdentifier = "collectionViewCell"
    var liftsToDisplay: [Lift]!
    var collectionView: UICollectionView!
    var plusButton: UIButton!
    var box: Box!
    var currentCellExerciseLog: ExerciseLog! // each cell in this item, displays the Exercise, and all the LiftLog items are contained by a ExerciseLog item.
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupBox()
        setupConstraints()
        selectionStyle = .none
        
        // Log item to store each Lift in the current Exercise. This exercise is potentially sent to Core Data if user decides to store workout
        currentCellExerciseLog = DatabaseController.createManagedObjectForEntity(.ExerciseLog) as! ExerciseLog
    }
    
    convenience init(withExercise exercise: Exercise, andIdentifier cellIdentifier: String?) {
        self.init(style: .default, reuseIdentifier: cellIdentifier)

        setupCell()
        setupPlusButton()
        setupCollectionView()
//        setDebugColors()
        
        // For this tableViewCell, retrieve the latest exerciseLogs for this exercise, and use the newest logged exercise to display in the collectionviewcells
        
        let exerciseLogs = exercise.loggedInstances as! Set<ExerciseLog>
        
        for log in exerciseLogs {
            for lift in log.lifts as! Set<Lift> {
                
                let sortDescriptor: [NSSortDescriptor] = [NSSortDescriptor(key: "datePerformed", ascending: false)]
                let sortedLifts = log.lifts?.sortedArray(using: sortDescriptor) as! [Lift]
                liftsToDisplay = sortedLifts
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Observers
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(doSomething), name: Notification.Name.keyboardsNextButtonDidPress, object: nil)
    }
    
    @objc private func doSomething() {
        print("observed")
    }
    
    // MARK: - HasNextCell protocol requirement
    
    // receives the indexPath of one of this TableViewCell's collectionViewCells, should either return the next cell, or make a new one if it doesnt exist, to allow for fast input of sets for the user
    func getNextCell(fromIndexPath indexPath: IndexPath) -> ExerciseSetCollectionViewCell {
        var ip = indexPath
        ip.row += 1
        
        let nextCollectionViewCell = collectionView.cellForItem(at: ip) as? ExerciseSetCollectionViewCell
        if let nextCell = nextCollectionViewCell {
            return nextCell
        } else {
            print("there was no next cell, so make it")
            insertNewCell()
        }
        return ExerciseSetCollectionViewCell()
    }
    
    // MARK: - Helpers
    
    private func setupPlusButton() {
        let shimmerHeight = box.boxFrame.shimmer.frame.height
        plusButton = UIButton(frame: CGRect(x: 0, y: 0, width: shimmerHeight, height: shimmerHeight))
        plusButton.setTitle("+", for: .normal)
        plusButton.setTitleColor(.light, for: .normal)
        plusButton.titleLabel?.font = UIFont.custom(style: .bold, ofSize: .bigger)
        plusButton.addTarget(self, action: #selector(plusButtonHandler), for: .touchUpInside)
        
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        
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
        print("*insertNewCell*")
        insertNewCell()
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
        print("did select some item")
    }
    
    // FIXME: - Make the + button add a new Lift
    
    func insertNewCell() {
        let itemCount = collectionView.numberOfItems(inSection: 0)
        
        // make new dummy value to be displayed
        let newLift = DatabaseController.createManagedObjectForEntity(.Lift) as! Lift
        newLift.datePerformed = Date() as NSDate
        newLift.reps = -1
        newLift.weight = 0
        newLift.owner = self.currentCellExerciseLog
        
        // FIXME: - remember to add entire ExerciseLog to the Workoutlog when user saves
        
        // add to dataSource and tableView
        let newIndexPath = IndexPath(item: itemCount, section: 0)
        liftsToDisplay.append(newLift)
        collectionView.insertItems(at: [newIndexPath]) // needs to have a matching Lift in the dataSource array
        
        // Make it selected and show keyboard
//        collectionView.selectItem(at: newIndexPath, animated: false, scrollPosition: .centeredHorizontally)
        UIView.animate(withDuration: 0.5,
                       animations: { 
                        self.collectionView.scrollToItem(at: newIndexPath, at: .right, animated: false)
        }) { _ in
            let c = self.collectionView.cellForItem(at: newIndexPath) as! ExerciseSetCollectionViewCell
            self.collectionView.selectItem(at: newIndexPath, animated: false, scrollPosition: .centeredHorizontally)
            c.tapHandler(sender: self)
        }
    }
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return liftsToDisplay.count
    }
    
    // MARK: - setup
    
    private func setupCollectionView() {
        
        // CollectionView
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionViewFrame = CGRect(x: box.boxFrame.frame.minX + Constant.components.Box.shimmerInset,
                                         y: box.boxFrame.frame.minY,
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
     
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: box.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: 10),
            contentView.widthAnchor.constraint(equalToConstant: Constant.UI.width),
                                    ])
    }
}

