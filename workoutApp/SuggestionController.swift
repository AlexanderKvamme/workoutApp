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
    
    typealias Suggestion = (header: String, sub: String)
    
    // MARK: - Properties
    
    private var receiveHandler: ((String) -> Void) = { _ in }
    
    fileprivate var header = UILabel(frame: CGRect.zero)
    fileprivate var stackOfSuggestions: UIStackView = UIStackView()
    fileprivate var suggestions: [Suggestion]? {
        didSet {
            if let suggestions = suggestions {
                updateSuggestionStack(withSuggestions: suggestions)
            }
        }
    }
    
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
}

// MARK: Private methods

fileprivate extension SuggestionController {
    
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
    
//    /// sort muscles into used and neverused. Prefer to display the never before used
//    func generateSuggestions() -> [Suggestion]? {
//        var mostRecentUseOfMuscle = [WorkoutLog]()
//        var musclesNeverUsed = [Muscle]()
//
//        // Fill arrays
//        for muscle in DatabaseFacade.fetchMuscles() {
//            if let mostRecentUse = muscle.mostRecentUse {
//                mostRecentUseOfMuscle.append(mostRecentUse)
//            } else {
//                musclesNeverUsed.append(muscle)
//            }
//        }
//
//        // If theres any muscles that have never been worked out
//        if musclesNeverUsed.count > 0 {
//            if let muscleName = musclesNeverUsed.first?.name {
//                return [("YOU HAVE YET TO WORKOUT:", muscleName)]
//            }
//        } else {
//            let workoutLogsByDate = mostRecentUseOfMuscle.sorted()
//            var suggestionsToReturn = [Suggestion]()
//
//            // return one or two suggestions
//            for log in workoutLogsByDate[0...1]{
//                let suggestion = makeSuggestion(for: log)
//                suggestionsToReturn.append(suggestion)
//            }
//            return suggestionsToReturn
//        }
//        return nil
        
        // FIXME: - Make suggestions based purely on most recent muscles
        
//        Get all muscles
//        Sort all muscles by dateperformed
//        for X muscles
//        generate suggestion from top 2 muscles
    /// sort muscles into used and neverused. Prefer to display the never before used
    func generateSuggestions() -> [Suggestion]? {
        let muscles = DatabaseFacade.fetchMuscles()
        
        let sortedMuscles = muscles.sortedByName()
        print("sosrted")
        for m in sortedMuscles {
            print(m.getName())
        }
        
        // FIXME: - return real values
        return [Suggestion]()
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

//    func makeSuggestion(for log: WorkoutLog) -> Suggestion {
//        let muscleName = log.getMuscleName()
//
//        if let timeOfWorkout = log.dateEnded {
//            let timeIntervalSinceWorkout = Date().timeIntervalSince(timeOfWorkout as Date)
//            let shortDate = timeIntervalSinceWorkout.asMinimalString()
//            return ("\(shortDate) SINCE LAST WORKOUT OF:", muscleName)
//        }
//        return ("X DAYS SINCE LAST WORKOUT OF:", muscleName)
//    }
    
    func makeSuggestion(for muscle: Muscle) -> Suggestion {
        
        let muscleName = muscle.getName()
        
        if let timeOfWorkout = muscle.lastPerformance() {
            let timeIntervalSinceWorkout = Date().timeIntervalSince(timeOfWorkout as Date)
            let shortDate = timeIntervalSinceWorkout.asMinimalString()
            return ("\(shortDate) SINCE LAST WORKOUT OF:", muscleName)
        }
        return ("X DAYS SINCE LAST WORKOUT OF:", muscleName)
    }
}

