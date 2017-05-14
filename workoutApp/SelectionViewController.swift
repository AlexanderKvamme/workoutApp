//
//  SelectionViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class SelectionViewController: UIViewController {
    
    var header: SelectionViewHeader!
    var buttons: [SelectionViewButton]!
    var buttonStack = UIStackView()
    
    init(header: SelectionViewHeader, buttons: [SelectionViewButton]) {
        self.header = header
        self.buttons = buttons
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .light
        
        // header
        view.addSubview(header)
        
        // stack
        buttonStack.axis = .vertical
        buttonStack.spacing = Constant.Layout.Selection.Stack.spacing
        
        for button in buttons {
            buttonStack.addArrangedSubview(button)
        }
        
        view.addSubview(buttonStack)
        
        setLayout()
    }
    
    func setLayout() {
        // header
        header.topAnchor.constraint(equalTo: view.topAnchor, constant: Constant.Layout.Selection.Header.spacingTop).isActive = true
        header.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        header.translatesAutoresizingMaskIntoConstraints = false
        
        // stack
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    }
}
