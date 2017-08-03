//
//  File.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol isBoxTableViewDataSource: UITableViewDataSource {
    var cellIdentifier: String {get set}
    var workoutStyleName: String? {get set}
    func refreshDataSource()
    func getData() -> [NSManagedObject]?
    init(workoutStyleName: String?)
}

