//
//  MeasurementStyleExtensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 24/10/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

extension MeasurementStyle {
    
    func getName() -> String {
        guard let name = self.name else { fatalError() }
        
        return name
    }
}
