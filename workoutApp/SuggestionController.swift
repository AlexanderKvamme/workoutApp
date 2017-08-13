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
    private var header = UILabel(frame: CGRect.zero)
    private var suggestions: [Suggestion]?
    private var stackOfSuggestions: UIStackView = UIStackView()
    
    var receiveHandler: ((String) -> Void) = { _ in }
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        suggestions = calculateSuggestions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        setupSuggestionStack()
        setupView()
    }
    
    // MARK: - Methods
    
    private func setupView() {
        setupHeader()
        setupStack()
    }
    
    private func setupHeader() {
        header.text = "SUGGESTIONS"
        header.textColor = .dark
        header.font = UIFont.custom(style: .bold, ofSize: .big)
        header.applyCustomAttributes(.medium)
        header.sizeToFit()
        view.addSubview(header)

        //Layout
        header.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            header.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30)
            ])
    }
    
    private func setupStack() {
        stackOfSuggestions.spacing = 8
        stackOfSuggestions.alignment = .leading
        stackOfSuggestions.axis = .vertical
        stackOfSuggestions.distribution = .equalSpacing
        stackOfSuggestions.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        stackOfSuggestions.isLayoutMarginsRelativeArrangement = true
        view.addSubview(stackOfSuggestions)
        
        // Layout
        stackOfSuggestions.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackOfSuggestions.topAnchor.constraint(equalTo: header.bottomAnchor),
            stackOfSuggestions.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackOfSuggestions.rightAnchor.constraint(equalTo: view.rightAnchor),
            stackOfSuggestions.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
    }
    
    private func makeSuggestionBox() -> SuggestionBox {
        let button = SuggestionBox()
        return button
    }
    
    private func calculateSuggestions() -> [Suggestion]? {
        
        var result: [Suggestion]? = nil
        
        // FIXME: - Calculate from core data and return suggestions if there is any
        
        var suggestions = [Suggestion]()
        for i in 0..<3 {
            let suggestion = ("\(i) WEEK SINCE LAST WORKOUT:", "LEGS")
            suggestions.append(suggestion)
        }
        
        if suggestions.count > 0 {
            result = suggestions
        }
        
        return result
    }
    
    private func setupSuggestionStack() {
        guard let suggestions = suggestions else { return }
        
        for suggestion in suggestions {
            let box = makeSuggestionBox()
            box.setSuggestionHeader(suggestion.header)
            box.setSuggestionSubheader(suggestion.sub)
            stackOfSuggestions.addArrangedSubview(box)
        }
    }
}

