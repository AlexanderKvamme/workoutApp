//
//  SummaryHeader.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 19/02/2023.
//  Copyright © 2023 Alexander Kvamme. All rights reserved.
//

import UIKit

final class Hat: UIView {
    
    var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 6
        label.font = UIFont.custom(style: .bold, ofSize: .medium)
        label.text = "23"
        label.textAlignment = .center
        label.textColor = .akDark
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


final class SummaryHeader: UIView {
    
    var label = UILabel()
    var hat = Hat()
    
    init() {
        super.init(frame: .zero)
        clipsToBounds = false
        
        label.font = UIFont.custom(style: .bold, ofSize: .biggest)
        label.text = "FINISHED"
        label.textColor = .akDark
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        addSubview(hat)
        hat.backgroundColor = akGray
        hat.snp.makeConstraints { make in
            make.centerX.equalTo(snp.right).offset(-4)
            make.centerY.equalTo(snp.top).offset(10)
        }
        
        hat.transform = hat.transform.rotated(by: .pi/10)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
