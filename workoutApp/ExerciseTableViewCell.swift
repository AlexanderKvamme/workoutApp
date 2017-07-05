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
    var collectionView: UICollectionView!
    var plusButton: UIButton!
    
    var box: Box!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupBox()
        setupConstraints()
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
    
    // MARK: - Helpers
    
    private func setupPlusButton() {
        let shimmerHeight = box.boxFrame.shimmer.frame.height
        plusButton = UIButton(frame: CGRect(x: 0, y: 0, width: shimmerHeight, height: shimmerHeight))
        plusButton.setTitle("+", for: .normal)
        plusButton.setTitleColor(.light, for: .normal)
        plusButton.titleLabel?.font = UIFont.custom(style: .bold, ofSize: .big)
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
        print("*ADD NEW SET*")
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
        let repFromLift = liftsToDisplay[indexPath.row].reps
        cell.setReps(repFromLift)
        return cell
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
        // Layout
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            collectionView.rightAnchor.constraint(equalTo: plusButton.leftAnchor),
//              collectionView.rightAnchor.constraint(equalTo: box.boxFrame.rightAnchor),
//            collectionView.leftAnchor.constraint(equalTo: box.boxFrame.leftAnchor),
//            collectionView.topAnchor.constraint(equalTo: box.boxFrame.topAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: box.boxFrame.bottomAnchor),
//            collectionView.heightAnchor.constraint(equalTo: box.boxFrame.heightAnchor),
//            collectionView.centerYAnchor.constraint(equalTo: box.boxFrame.centerYAnchor),
//            ])
    }
    
    private func setupCell() {
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

