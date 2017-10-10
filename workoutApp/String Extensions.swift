//
//  String Extensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 10/10/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

extension String {
    func isEmpty() -> Bool {
        return self == ""
    }
    
    func hasCharacters() -> Bool {
        return self != ""
    }
}
