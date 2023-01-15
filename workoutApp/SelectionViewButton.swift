//
//  SelectionViewButton.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

public class SelectionViewButton: UIView {
    
    var button: UIButton!
    var headerLabel: UILabel!
    var subheaderLabel: UILabel!
    var stack = UIStackView()
    
    init(header: String, subheader: String) {
        super.init(frame: .zero)
        
        headerLabel = UILabel()
        headerLabel.text = header.uppercased()
        headerLabel.font = UIFont.custom(style: .bold, ofSize: .big)
        headerLabel.textAlignment = .center
        headerLabel.textColor = UIColor.akDark
        headerLabel.sizeToFit()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.isUserInteractionEnabled = false
        
        subheaderLabel = UILabel()
        subheaderLabel.text = subheader.uppercased()
        subheaderLabel.font = UIFont.custom(style: .bold, ofSize: .small)
        subheaderLabel.applyCustomAttributes(.medium)
        subheaderLabel.textAlignment = .center
        subheaderLabel.textColor = UIColor.akDark.withAlphaComponent(.opacity.faded.rawValue)
        subheaderLabel.sizeToFit()
        subheaderLabel.translatesAutoresizingMaskIntoConstraints = false
        subheaderLabel.isUserInteractionEnabled = false
        
        button = UIButton(frame: frame)
        button.addTarget(self, action: #selector(handleButtonTap(_:)), for: .touchUpInside)
        
        setupConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        addSubview(button)
        addSubview(stack)
        stack.addArrangedSubview(headerLabel)
        stack.addArrangedSubview(subheaderLabel)
        
        stack.isUserInteractionEnabled = false
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 4
        backgroundColor = .white
        layer.cornerRadius = 16
        
        stack.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        snp.makeConstraints { make in
            make.height.equalTo(80)
            make.width.equalTo(UIScreen.main.bounds.width-48)
        }
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // UI components
    @objc func handleButtonTap(_ sender: SelectionViewButton) {
        // Override for actual use
        showNotYetImplementedModal()
    }
    
    func showNotYetImplementedModal() {
        let alert = CustomAlertView(messageContent: "This feature is not yet implemented!")
        alert.show(animated: true)
    }
}
