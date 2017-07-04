//
//  ExerciseTableViewCell.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private let collectionViewReuseIdentifier = "collectionViewCell"
    var liftsToDisplay: [Lift]!
    
    var box: Box!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
        setupBox()
        setupConstraints()
    }
    
    convenience init(withExercise exercise: Exercise, andIdentifier cellIdentifier: String?) {
        self.init(style: .default, reuseIdentifier: cellIdentifier)

        // CollectionView
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: box.boxFrame.frame, collectionViewLayout: layout)
        collectionView.register(ExerciseSetCollectionViewCell.self, forCellWithReuseIdentifier: collectionViewReuseIdentifier)
        collectionView.backgroundColor = .green
        collectionView.alpha = 0.5
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        
        // For this tableViewCell, retrieve the latest exerciseLogs for this exercise, and use the newest logged exercise to display in the collectionviewcells
        
        // print("ExerciseSetCollectionView receives \(exercise.name!)")
        
        let exerciseLogs = exercise.loggedInstances as! Set<ExerciseLog>
        
        for log in exerciseLogs {
            print("new exerciseLog:", log.datePerformed)
            for lift in log.lifts as! Set<Lift> {
                
                let sortDescriptor: [NSSortDescriptor] = [NSSortDescriptor(key: "datePerformed", ascending: false)]
                let sortedLifts = log.lifts?.sortedArray(using: sortDescriptor) as! [Lift]
                liftsToDisplay = sortedLifts
                
                print("new rep logged: \(lift.reps)")
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CollectionView delegate methods
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewReuseIdentifier, for: indexPath) as! ExerciseSetCollectionViewCell
        let repFromLift = liftsToDisplay[indexPath.row].reps
        cell.setReps(repFromLift)
        return cell
    }
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return liftsToDisplay.count
    }
    
    // MARK: - setup
    
    private func setup() {
        backgroundColor = .clear
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

