//
//  SelectionViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class SelectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .light
        
        // make header
        
        let developmentHeader = selectionViewHeader(header: "SELECT", subheader: "DEVELOPMENT")
        developmentHeader.center.y = developmentHeader.center.y + 100
        
        // make buttons
        let statisticsButton = selectionViewButton(header: "STATISTICS", subheader: "292 EXERCISES")
        statisticsButton.center.y = statisticsButton.center.y + 250
        
        let workoutHistoryButton = selectionViewButton(header: "WORKOUT HISTORY", subheader: "99 WORKOUTS")
        workoutHistoryButton.center.y = workoutHistoryButton.center.y + 300
        
        view.addSubview(developmentHeader)
        view.addSubview(statisticsButton)
        view.addSubview(workoutHistoryButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
