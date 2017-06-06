//
//  PickerViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 04/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

/*
 This PickerView is used to pick workout styles/muscles. It is actually a ViewController containing a tableView. Since these are fantastically customizable.
 */

import UIKit

class PickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var table: UITableView!
    var header: TwoLabelStack!
    var footer: ButtonFooter!
    var selectedIndexPath: IndexPath?
    
    let tableVerticalInset: CGFloat = 102
    
    let workoutStyles = ["Normal",
                         "Bodyweight",
                         "Weighted",
                         "Assisted"]
    
//    let workoutStyles = ["Normal",
//                         "Bodyweight",
//                         "Weighted",
//                         "Assisted",
//                         "Cardio2",
//                         "Extreme3",
//                         "Relaxed4",
//                         "Fucked up5",
//                         "All biziz1",
//                         "No stress workout12",
//                         "Team workout13",
//                         "Real-axed14",
//                         "Cardio15",
//                         "Extreme16",
//                         "Relaxed23",
//                         "Fucked up24",
//                         "All bizniz25", // [16]
//                         "No stress workout26",
//                         "Team workout27",
//                         "Real-axed28"]
    
    let cellIdentifier = "cellIdentifier"
    
    let fontWhenSelected = UIFont.custom(style: .bold, ofSize: .big)
    let textColorWhenSelected = UIColor.darkest
    let textColorWhenDeselected = UIColor.faded
    let fontWhenDeselected = UIFont.custom(style: .bold, ofSize: .medium)
    let screenWidth = UIScreen.main.bounds.width
    let inset: CGFloat = 20
    
    init(){
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup
        view.backgroundColor = UIColor.light
        hidesBottomBarWhenPushed = true
        
        // header
        let headerFrame = CGRect(x: 0, y: 50,
                                 width: Constant.UI.width,
                                 height: 100)
        header = TwoLabelStack(frame: headerFrame,
                                   topText: "TYPE",
                                   topFont: .custom(style: .bold, ofSize: .big),
                                   topColor: .secondary,
                                   bottomText: "",
                                   bottomFont: .custom(style: .medium, ofSize: .small), bottomColor: .black, fadedBottomLabel: false)
        view.addSubview(header)
        
        // Table
        table = UITableView(frame: CGRect(x: inset,
                                          y: header.frame.maxY + 50,
                                          width: screenWidth - 2*inset,
                                          height: 200))
        table.reloadData()
        
        // MARK - Table setup
        
        // Table
        table.register(PickerCell.self, forCellReuseIdentifier: cellIdentifier)
        table.backgroundColor = .clear
        
        table.dataSource = self
        table.delegate = self
        
        view.addSubview(table)
        
        // Footer
        footer = ButtonFooter(withColor: .secondary)
        footer.frame.origin.y = Constant.UI.height - footer.frame.height
        footer.cancelButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        view.addSubview(footer)
        
        // table setup
        setupTable()

        view.setNeedsLayout()
    }
    
    // MARK: - Data Source
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PickerCell
        configure(cell, forIndexPath: indexPath)
        cell.label.text = workoutStyles[indexPath.row].uppercased()
        cell.sizeToFit()
        
        return cell
    }
    
    func configure(_ cell: PickerCell, forIndexPath indexPath: IndexPath) {
     
        print("IN CONFIGURE")
        if selectedIndexPath == indexPath {
            print("- was same. Make look selected")
            cell.label.font = fontWhenSelected
            cell.label.textColor = textColorWhenSelected
        } else {
            print("- was same. Make look selected")
            cell.label.font = fontWhenDeselected
            cell.label.textColor = textColorWhenDeselected
        }
    }
    
    // MARK: - TableView Delegate methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("rows: ", workoutStyles.count)
        return workoutStyles.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil
        } else {
            // remove previous selection
            if let previousSelectedIndexPath = selectedIndexPath {
            
                if let previousSelectedCell = tableView.cellForRow(at: previousSelectedIndexPath) as? PickerCell {
                    configure(previousSelectedCell, forIndexPath: indexPath)
                }
            }
            // update selection
            selectedIndexPath = indexPath
        }
        let selectedCell = tableView.cellForRow(at: indexPath)! as! PickerCell
        configure(selectedCell, forIndexPath: indexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - Helpers
    
    func setupTable() {
        table.translatesAutoresizingMaskIntoConstraints = false
        table.clipsToBounds = true
        table.allowsMultipleSelection = false
        
        table.separatorStyle = .none
        
        let tableBotConstraint = table.bottomAnchor.constraint(equalTo: footer.topAnchor, constant: 0)
        let tableTopConstraint = table.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 0)
        
        NSLayoutConstraint.activate([
            tableBotConstraint,
            tableTopConstraint,
            table.widthAnchor.constraint(equalToConstant: screenWidth),
            ])
        
        table.layoutIfNeeded()
        
        // disable scrolling if all content fits in the frame
        let tableHeight = table.frame.height
        let contentHeight = table.contentSize.height
        
        if contentHeight > tableHeight {
            table.isScrollEnabled = true
        } else {
            table.isScrollEnabled = false
            drawDiagonalLineThroughTable()
        }
        
        if tableHeight > contentHeight {
            let verticalOffset = (tableHeight - contentHeight)/2
            table.contentInset = UIEdgeInsets(top: verticalOffset, left: 0, bottom: verticalOffset, right: 0)
        } else if contentHeight > tableHeight {
            // If you have to scroll anyways, make insets to center content in the screen to make it look nicer
            
            tableBotConstraint.constant = -tableVerticalInset
            tableTopConstraint.constant = tableVerticalInset
            table.updateConstraints()
        }
    }
    
    func setDebugColors() {
        table.backgroundColor = .green
        header.backgroundColor = .yellow
                footer.backgroundColor = .purple
    }
    
    private func drawDiagonalLineThroughTable() {
        let v = UIView(frame: table.frame)
        v.frame.size = CGSize(width: v.frame.height - 200, height:  v.frame.width - 200)
        print("vframe:", v.frame)
        //        v.center = table.center
        v.center.y = table.center.y + CGFloat(tableVerticalInset)
        v.center.x = table.center.x
        drawDiagonalLineThrough(v, inView: view)
    }
    
    // MARK: - Selectors
    
    func dismissView() {
        print("selector triggered")
        navigationController?.popViewController(animated: false)
    }
}

