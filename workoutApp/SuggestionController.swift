//
//  SuggestionController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 13/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//


import Foundation
import UIKit

/// Makes and presents suggestionboxes. Updates every time the view appears.
class SuggestionController: UIViewController {
    
    typealias Suggestion = Muscle
    
    // MARK: - Properties
    
    fileprivate var header = UILabel(frame: CGRect.zero)
    private var receiveHandler: ((String) -> Void) = { _ in }
    fileprivate var stackOfSuggestions: UIStackView = UIStackView()
    fileprivate var suggestionBoxes: [SuggestionBox]!
    fileprivate var suggestedMuscles: [Muscle]!
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        renewSuggestionBoxes()
    }
}

fileprivate extension SuggestionController {
    
    // MARK: Private methods
    
    func renewSuggestionBoxes() {
        let suggestionBoxes = makeSuggestionBoxes()
        
        stackOfSuggestions.removeArrangedSubviews()

        for box in suggestionBoxes {
            stackOfSuggestions.addArrangedSubview(box)
        }
    }

    func makeSuggestionBoxes() -> [SuggestionBox] {
        var boxes = [SuggestionBox]()
        let sortedMuscles = DatabaseFacade.fetchMuscles(with: .mostRecentUse, ascending: true)
        
        let musclesToDisplay = Array(sortedMuscles[0...2])
        suggestedMuscles = musclesToDisplay
        
        for (i, suggestedMuscle) in musclesToDisplay.enumerated() {
            let box = SuggestionBox(withMuscle: suggestedMuscle)
            box.button.addTarget(self, action: #selector(testPrint), for: .touchUpInside)
            box.button.tag = i
            boxes.append(box)
        }
        return boxes
    }
    
    @objc func testPrint(sender:UIButton) {
        
        print("Would present workoutpicker for: ", suggestedMuscles[sender.tag])
        
        let muscle = suggestedMuscles[sender.tag]
        let muscleBasedWorkoutPicker = MuscleBasedWorkoutTableController(muscle: muscle)
        navigationController?.pushViewController(muscleBasedWorkoutPicker, animated: true)
    }
    
    // MARK: Setup methods
    
    func setupView() {
        setupHeader()
        setupStack()
    }
    
    func setupHeader() {
        header.text = "SUGGESTIONS"
        header.textColor = .dark
        header.font = UIFont.custom(style: .bold, ofSize: .big)
        header.applyCustomAttributes(.medium)
        header.sizeToFit()
        view.addSubview(header)
        
        header.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            header.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30)
            ])
    }
    
    func setupStack() {
        stackOfSuggestions.spacing = 8
        stackOfSuggestions.alignment = .leading
        stackOfSuggestions.axis = .vertical
        stackOfSuggestions.distribution = .equalSpacing
        stackOfSuggestions.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        stackOfSuggestions.isLayoutMarginsRelativeArrangement = true
        view.addSubview(stackOfSuggestions)
        
        stackOfSuggestions.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackOfSuggestions.topAnchor.constraint(equalTo: header.bottomAnchor),
            stackOfSuggestions.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackOfSuggestions.rightAnchor.constraint(equalTo: view.rightAnchor),
            stackOfSuggestions.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
    }
}

