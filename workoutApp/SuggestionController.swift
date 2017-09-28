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
    fileprivate var suggestionBoxes: [SuggestionBox]!
    
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
        let suggestions = makeSuggestionsArray()
        let suggestionBoxes = makeSuggestionBoxes(from: suggestions)
        
        stackOfSuggestions.removeArrangedSubviews()

        for box in suggestionBoxes {
            stackOfSuggestions.addArrangedSubview(box)
        }
    }
    
    func makeSuggestionsArray() -> [Suggestion] {
        let sortedMuscles = DatabaseFacade.fetchMuscles(with: .mostRecentUse, ascending: true)
        var suggestions = [Suggestion]()
        
        for muscle in sortedMuscles[0...2] {
            let suggestion = makeSuggestion(for: muscle)
            suggestions.append(suggestion)
        }
        return suggestions
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
    
    func makeSuggestion(for muscle: Muscle) -> Suggestion {
        
        if muscle.performanceCount == 0 {
            return ("YET TO BE WORKED OUT", "\(muscle.getName())")
        }
        
        // Those that has been performed before
        if let timeOfWorkout = muscle.lastPerformance() {
            let timeIntervalSinceWorkout = Date().timeIntervalSince(timeOfWorkout as Date)
            let shortDate = timeIntervalSinceWorkout.asMinimalString()
            return ("\(shortDate) SINCE LAST WORKOUT OF:", muscle.getName())
        }
        
        // If time of last workout of this workout is not 0, but cant be found
        return ("X DAYS SINCE LAST WORKOUT OF:", muscle.getName())
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

