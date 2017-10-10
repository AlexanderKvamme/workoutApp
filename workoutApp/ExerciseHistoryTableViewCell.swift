//
//  ExerciseHistoryCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 18/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/*
 ExerciseTableViewCell is one cell in a table of exercises. So each cell represents one exercise, and contains any number of sets to be performed for the exercise.
 */

class ExerciseHistoryTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var liftsToDisplay: [Lift]!
    var collectionView: UICollectionView!
    private var plusButton: UIButton!
    private var verticalInsetForBox: CGFloat = 10
    private let unweightedCellID = "unweightedCell"
    private let weightedCellID = "weightedCell"
    private let unweightedHistoryLiftCellID = "unweightedHistoryLiftCellID"
    private var persistentContainer = NSPersistentContainer(name: Constant.coreData.name)
    var box: Box!
    
    weak var owner: ExerciseHistoryTableViewDataSource!
    
    // MARK: - Initializers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    init(withExerciseLog exerciseLog: ExerciseLog, andLifts lifts: [Lift], andIdentifier cellIdentifier: String) {
        super.init(style: .default, reuseIdentifier: cellIdentifier)
        
        print("ExerciseHistoryTableViewCell")
        
        liftsToDisplay = lifts
        
        setupBox()
        setupConstraints()
        setupCell()
        setupCollectionView()
        
        selectionStyle = .none
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
    
    func setDebugColors() {
        self.collectionView.backgroundColor = .green
        self.collectionView.alpha = 0.5
    }
    
    // MARK: - CollectionView delegate methods
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: LiftCell!
        
        // FIXME: - removing to test new cell system
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewReuseIdentifier, for: indexPath) as! ExerciseHistorySetCollectionViewCell
        
//        cell.owner = self
        
//        if self.exercise.isWeighted() {
        
        // FIXME:
        if 1 == 1 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: unweightedHistoryLiftCellID, for: indexPath) as! UnweightedHistoryLiftCell
        } else {
//            cell = collectionView.dequeueReusableCell(withReuseIdentifier: unweightedCellID, for: indexPath) as! UnweightedLiftCell
        }
        
        // FIXME: - må ha tilgang til eierens dataSource for å kunne redigere set
//        cell.owner = self
        
        let liftToDisplay = liftsToDisplay[indexPath.row]
        let repFromLift = liftToDisplay.reps
        cell.setReps(repFromLift)
        cell.makeRepTextBold()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("did select some item at indexpath \(indexPath)")
    }
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return liftsToDisplay.count
    }
    
    // MARK: - setup methods
    
    private func setupCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionViewFrame = CGRect(x: box.boxFrame.frame.minX + Constant.components.Box.shimmerInset,
                                         y: box.boxFrame.frame.minY + verticalInsetForBox,
                                         width: box.boxFrame.frame.width - 2*Constant.components.Box.shimmerInset,
                                         height: box.boxFrame.frame.height)
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        
        // Register cells
        collectionView.register(UnweightedLiftCell.self, forCellWithReuseIdentifier: unweightedCellID)
        collectionView.register(WeightedLiftCell.self, forCellWithReuseIdentifier: weightedCellID)
        collectionView.register(UnweightedHistoryLiftCell.self ,forCellWithReuseIdentifier: unweightedHistoryLiftCellID)
        
        collectionView.alpha = 1
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        
        collectionView.frame.size = CGSize(width: collectionView.frame.width,
                                           height: collectionView.frame.height)
    }
    
    private func setupCell() {
        backgroundColor = .light
    }
    
    private func setupBox() {
        let boxFactory = BoxFactory.makeFactory(type: .ExerciseTableCellBox)
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

