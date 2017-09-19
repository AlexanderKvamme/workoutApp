//
//  SuggestionController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 13/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//


import Foundation
import UIKit


class SuggestionController: UIViewController {
    
    typealias Suggestion = (header: String, sub: String)
    
    // MARK: - Properties
    fileprivate var header = UILabel(frame: CGRect.zero)
    fileprivate var stackOfSuggestions: UIStackView = UIStackView()
    fileprivate var suggestions: [Suggestion]? {
        didSet {
            if let suggestions = suggestions {
                updateSuggestionStack(withSuggestions: suggestions)
            }
        }
    }
    
    
    private var receiveHandler: ((String) -> Void) = { _ in }
    
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
        self.suggestions = generateSuggestions()
    }
    
    // MARK: - Methods
}

private extension SuggestionController {
    
    // MARK: Private methods
    
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
    
    /// sort muscles into used and neverused. Prefer to display the never before used
    func generateSuggestions() -> [Suggestion]? {
        var previousUsesOfMuscles = [WorkoutLog]()
        var musclesNeverUsed = [Muscle]()
        
        // Fill arrays
        for muscle in DatabaseFacade.fetchMuscles() {
            if let mostRecentUse = muscle.mostRecentUse {
                previousUsesOfMuscles.append(mostRecentUse)
            } else {
                musclesNeverUsed.append(muscle)
            }
        }
        
        // If theres any never before used
        if musclesNeverUsed.count > 0 {
            if let someMuscle = musclesNeverUsed.first {
                return [("YOU HAVE YET TO WORKOUT:", someMuscle.name!)]
            }
        } else {
            let workoutLogsByDate = previousUsesOfMuscles.sorted()
            var suggestionsToReturn = [Suggestion]()
            
            // return one or two suggestions
            for (i, log) in workoutLogsByDate.enumerated() where i < 2 {
                
                guard let timeOfWorkout = log.dateEnded,
                    let workoutName = log.design?.muscleUsed?.name else { break }
                
                let timeIntervalSinceWorkout = Date().timeIntervalSince(timeOfWorkout as Date)
                let shortenedTimeString = timeIntervalSinceWorkout.asMinimalString()
                let suggestion = ("\(shortenedTimeString) SINCE LAST WORKOUT:", workoutName)
                
                suggestionsToReturn.append(suggestion)
            }
            return suggestionsToReturn
        }
        
        return nil
    }
    
    func updateSuggestionStack(withSuggestions suggestions: [Suggestion]) {
        let suggestionBoxes = makeSuggestionBoxes(from: suggestions)
        
        stackOfSuggestions.removeArrangedSubviews()
        
        for box in suggestionBoxes {
            stackOfSuggestions.addArrangedSubview(box)
        }
    }
    
    func makeSuggestionBoxes(from suggestions: [Suggestion] ) -> [SuggestionBox] {
        
        var boxes = [SuggestionBox]()
        
        for suggestion in suggestions {
            let box = SuggestionBox()
            box.setSuggestionHeader(suggestion.header)
            box.setSuggestionSubheader(suggestion.sub)
            boxes.append(box)
        }
        return boxes
    }
    
//    /// shortens to "10M", "10H", "10D", "10W" .etc
//    func stringifyTimeInterval(_ timeInterval: TimeInterval) -> String {
//        
//        let s = timeInterval
//        let m = Int(s/60)
//        let h = Int(m/60)
//        let d = Int(h/24)
//        
//        if d > 0 {
//            return "\(d)D"
//        } else if h > 0 {
//            return "\(h)H"
//        } else if m > 0 {
//            return "\(m)M"
//        } else {
//            return "\(s)S"
//        }
//    }
    

}

