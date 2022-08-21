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
        subheaderLabel.font = UIFont.custom(style: .bold, ofSize: .small)
        subheaderLabel.applyCustomAttributes(.medium)
        subheaderLabel.textAlignment = .center
        subheaderLabel.textColor = UIColor.dark
        subheaderLabel.sizeToFit()
        subheaderLabel.translatesAutoresizingMaskIntoConstraints = false
        subheaderLabel.isUserInteractionEnabled = false
        
        button = UIButton(frame: frame)
        button.addTarget(self, action: #selector(handleButtonTap(_:)), for: .touchUpInside)
        
        button.backgroundColor = .green
        setupConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        addSubview(button)
        addSubview(headerLabel)
        addSubview(subheaderLabel)
        headerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        subheaderLabel.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        // self
        let combinedLabelHeight = subheaderLabel.frame.height + headerLabel.frame.height
        snp.makeConstraints { make in
            make.height.equalTo(combinedLabelHeight)
            make.width.equalTo(200)
            make.top.equalTo(headerLabel)
            make.bottom.equalTo(subheaderLabel)
        }
    }
    
    // UI components
    @objc func handleButtonTap(_ sender: SelectionViewButton) {
        // Override for actual use
        showNotYetImplementedModal()
    }
    
    func showNotYetImplementedModal() {
        let alert = CustomAlertView(type: .error, messageContent: "This feature is not yet implemented!")
        alert.show(animated: true)
    }
}
