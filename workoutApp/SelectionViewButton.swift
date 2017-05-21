//
//  SelectionViewButton.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

public class SelectionViewButton: UIView {
    
    var button: UIButton!
    var headerLabel: UILabel!
    var subheaderLabel: UILabel!
    
    init(header: String, subheader: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
        
        headerLabel = UILabel()
        headerLabel.text = header.uppercased()
        headerLabel.font = UIFont.custom(style: .bold, ofSize: .big)
        headerLabel.textAlignment = .center
        headerLabel.textColor = UIColor.dark
        headerLabel.sizeToFit()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.isUserInteractionEnabled = false
        
        subheaderLabel = UILabel()
        subheaderLabel.text = subheader.uppercased()
        subheaderLabel.font = UIFont.custom(style: .medium, ofSize: .small)
        subheaderLabel.textAlignment = .center
        subheaderLabel.textColor = UIColor.dark
        subheaderLabel.sizeToFit()
        subheaderLabel.translatesAutoresizingMaskIntoConstraints = false
        subheaderLabel.isUserInteractionEnabled = false
        
        button = UIButton(frame: frame)
        button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        
        addSubview(button)
        addSubview(headerLabel)
        addSubview(subheaderLabel)
        
        setupConstraints()
//        addColorToFrames()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        // Labels
        headerLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        subheaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor).isActive = true
        subheaderLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    
        // View
        let combinedLabelHeight = subheaderLabel.frame.height + headerLabel.frame.height
        heightAnchor.constraint(equalToConstant: combinedLabelHeight).isActive = true
        widthAnchor.constraint(equalToConstant: 200).isActive = true
        topAnchor.constraint(equalTo: headerLabel.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: subheaderLabel.bottomAnchor).isActive = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addColorToFrames() {
        self.backgroundColor = .yellow
        headerLabel.backgroundColor = .green
        subheaderLabel.backgroundColor = .blue
    }
    
    // UI components
    func handleButtonTap() {
        print("something")
        showModal()
    }
    
    func showModal() {
        let alert = CustomAlertView(type: .error, messageContent: "this feature is not yet implemented!")
        //        let alert = CustomAlertView(type: .message, messageContent: "this feature is not yet implemented!")
        alert.show(animated: true)
    }
}
