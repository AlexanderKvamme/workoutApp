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

class PickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, isStringSender {
    
    var table: UITableView!
    var header: TwoLabelStack!
    var footer: ButtonFooter!
    var selectedIndexPath: IndexPath?
    
    let tableVerticalInset: CGFloat = 102
    
    var selectionChoices = [String]()
    var stringToSelect: String?
    
    let cellIdentifier = "cellIdentifier"
    var currentlySelectedString: String?
    
    let fontWhenSelected = UIFont.custom(style: .bold, ofSize: .big)
    let textColorWhenSelected = UIColor.darkest
    let textColorWhenDeselected = UIColor.faded
    let fontWhenDeselected = UIFont.custom(style: .bold, ofSize: .medium)
    let screenWidth = UIScreen.main.bounds.width
    let inset: CGFloat = 20
    
    weak var delegate: isStringReceiver?
    
    func sendStringBack(_ string: String) {
        delegate?.receive(string)
    }
    
    init(withChoices choices: [String], withPreselection preselection: String?) {
        // FIXME: - start out with multieple workouts selected, so make this an optional array
        if let preselection = preselection {
            self.currentlySelectedString = preselection
            print("stored \(preselection) in currentlySelected")
        }
        
        selectionChoices = choices
        
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup
        view.backgroundColor = UIColor.light
        hidesBottomBarWhenPushed = true
        
        // Header
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
        
        // MARK: - Table setup
        
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
        footer.approveButton.addTarget(self, action: #selector(confirmAndDismiss), for: .touchUpInside)
        
        view.addSubview(footer)
        
        setupTable()
        
        // preselection
        if let stringToSelect = currentlySelectedString {
            selectRow(withString: stringToSelect)
        }
        
        table.reloadData()
        view.setNeedsLayout()
    }
    
    // MARK: - Data Source
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PickerCell
        configure(cell, forIndexPath: indexPath)
        cell.label.text = selectionChoices[indexPath.row].uppercased()
        cell.label.applyCustomAttributes(.more)
        cell.sizeToFit()
        
        return cell
    }
    
    func configure(_ cell: PickerCell, forIndexPath indexPath: IndexPath) {
     
        if selectedIndexPath == indexPath {
            cell.label.font = fontWhenSelected
            cell.label.textColor = textColorWhenSelected
        } else {
            cell.label.font = fontWhenDeselected
            cell.label.textColor = textColorWhenDeselected
        }
    }
    
    // MARK: - TableView Delegate methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectionChoices.count
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
        currentlySelectedString = selectedCell.label.text
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
    
    func selectRow(withString string: String) {
        
        print("tryna select \(string) in selectRow")
        print(" tryna find it in this array \(selectionChoices)")
        
        if let indexOfA = selectionChoices.index(of: string) {
            print("found it in \(indexOfA)")
            let ip = IndexPath(row: indexOfA, section: 0)
            table.selectRow(at: ip, animated: false, scrollPosition: .none)
            selectedIndexPath = ip
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
        v.center.y = table.center.y + CGFloat(tableVerticalInset)
        v.center.x = table.center.x
        drawDiagonalLineThrough(v, inView: view)
    }
    
    // MARK: - Selectors
    
    func dismissView() {
        navigationController?.popViewController(animated: false)
    }
    
    func confirmAndDismiss() {
        if let currentlySelectedString = currentlySelectedString {
            delegate?.receive(currentlySelectedString)
        } else {
            delegate?.receive("NORMAL")
        }
        navigationController?.popViewController(animated: false)
    }
}

