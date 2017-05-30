//
//  File.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

class WorkoutTableViewDataSource: NSObject, UITableViewDataSource {
    
    let cellIdentifier: String = "BoxCell"
    var workoutStyle: String!
    
    init(workoutStyle: String) {
        super.init()
        self.workoutStyle = workoutStyle
        print(" data source init")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("making a cell")
        var cell: WorkoutBoxCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WorkoutBoxCell
        cell = WorkoutBoxCell(style: .default, reuseIdentifier: cellIdentifier)
        print(cell.frame)
        cell.box.setTitle("Bam")
        cell.box.setSubHeader(workoutStyle)
        return cell
    }
}
