//
//  ExerciseCollectionViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

private let reuseIdentifier = "exerciseSetCell"

class ExerciseSetCollectionViewController: UICollectionViewController {

    var collectionViewOfSets: ExerciseSetCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blue
        view.alpha = 0.5

        // Register cell classes
        self.collectionView!.register(ExerciseSetCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    init(withExercise exercise: Exercise, forFrame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
        view.frame = forFrame
        setupSetCollectionViews(exercise)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Other things
    
    private func setupSetCollectionViews(_ exercise: Exercise) {
        print("in collectionVC tryna make a collectionview from \(exercise.name)")
        //        collectionViewOfSets = ExerciseSetCollectionViewController(withExercise: exercise)
        collectionViewOfSets = ExerciseSetCollectionView(withExercise: exercise)
//        collectionViewOfSets.frame = box.boxFrame.frame // the graphic part of the box
        collectionViewOfSets.backgroundColor = .purple
        collectionViewOfSets.alpha = 0.5
        view.addSubview(collectionViewOfSets)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
