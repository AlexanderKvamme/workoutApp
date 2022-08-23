//
//  PickerViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 04/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/// This PickerView is used to pick workout styles/muscles. It is actually a ViewController containing a tableView. Since these are fantastically customizable.
class PickerController<T: PickableEntity>: UIViewController, UITableViewDelegate, UITableViewDataSource, isStringSender {
    
    // MARK: - Properties
    var header: TwoLabelStack = {
        let labelStack = TwoLabelStack(frame: .zero, topText: "SELECT", topFont: .custom(style: .bold, ofSize: .big), topColor: .akDark, bottomText: "", bottomFont: .custom(style: .medium, ofSize: .small), bottomColor: .akDark, fadedBottomLabel: false)
        return labelStack
    }()
    var table: UITableView!
    var footer: ButtonFooter!
    var selectedIndexPath: IndexPath?
    var selectionChoices: [T]!
    var selectedPickable: T!
    let tableVerticalInset: CGFloat = 102
    var stringToSelect: String?
    let cellIdentifier = "cellIdentifier"
    let screenWidth = UIScreen.main.bounds.width
    let inset: CGFloat = 20
    
    // Delegates
    weak var stringReceiver: isStringReceiver?
    weak var pickableReceiver: PickableReceiver?
    
    // Protocol conformance: isStringSender
    func sendStringBack(_ string: String) {
        stringReceiver?.receiveString(string)
    }

    // MARK: - Initializers

    init(withPicksFrom array: [PickableEntity], withPreselection preselection: Pickable) {
        super.init(nibName: nil, bundle: nil)
        selectionChoices = array as! [T]
        selectedPickable = preselection
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupFooter()
        setupTable()
        
        // Preselection
        selectRow(withPickable: selectedPickable)
        
        table.reloadData()
        view.setNeedsLayout()
    }
    
    // MARK: - Methods
    
    // MARK: Data Source
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PickerCell
        configure(cell, forIndexPath: indexPath)
        cell.label.text = selectionChoices[indexPath.row].name
        cell.label.applyCustomAttributes(.more)
        return cell
    }
    
    func configure(_ cell: PickerCell, forIndexPath indexPath: IndexPath) {
        if selectedIndexPath == indexPath {
            cell.label.font = Constant.components.exerciseTableCells.fontWhenSelected
            cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenSelected
        } else {
            cell.label.font = Constant.components.exerciseTableCells.fontWhenDeselected
            cell.label.textColor = Constant.components.exerciseTableCells.textColorWhenDeselected
        }
    }
    
    // MARK: TableView Delegate methods
    // - Generic classes cannot have protocol conformance in extensions
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.pickers.rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectionChoices.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Make look deselected or selected
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
            selectedPickable = selectionChoices[indexPath.row]
        }
        let selectedCell = tableView.cellForRow(at: indexPath)! as! PickerCell
        configure(selectedCell, forIndexPath: indexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: Helpers
    
    private func setupView() {
        setupHeader()
        view.backgroundColor = .akLight
    }
    
    private func setupFooter() {
        footer = ButtonFooter(withColor: .secondary)
        footer.frame.origin.y = Constant.UI.height - footer.frame.height
        footer.cancelButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        footer.approveButton.addTarget(self, action: #selector(confirmAndDismiss), for: .touchUpInside)
        
        view.addSubview(footer)
    }
    
    private func setupHeader() {
        header.frame = CGRect(x: 0, y: 50, width: Constant.UI.width, height: 100)
        view.addSubview(header)
    }
    
    func setHeaderTitle(_ newTitle: String) {
        header.topLabel.text = newTitle
    }
    
    private func setupTable() {
        table = UITableView()
        table.reloadData()
        
        table.register(PickerCell.self, forCellReuseIdentifier: cellIdentifier)
        table.backgroundColor = .clear
        
        table.dataSource = self
        table.delegate = self
        
        view.addSubview(table)
    
        table.clipsToBounds = true
        table.allowsMultipleSelection = false
        
        table.separatorStyle = .none
        
        let tableBotConstraint = table.bottomAnchor.constraint(equalTo: footer.topAnchor, constant: 0)
        let tableTopConstraint = table.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 0)
        
        table.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            table.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableTopConstraint,
            tableBotConstraint,
            table.widthAnchor.constraint(equalToConstant: screenWidth),
            ])
        
        table.layoutIfNeeded()
        
        // disable scrolling if all content fits in the frame
        let tableHeight = table.frame.height
        let contentHeight = table.contentSize.height
        
        // Draw diagonal line if table is not scrollable
        if contentHeight > tableHeight {
            table.isScrollEnabled = true
        } else {
            table.isScrollEnabled = false
        }
        
        // Update insets
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
    
    func selectRow(withPickable pickable: Pickable) {
        
        guard let indexOfPickable = selectionChoices.index(where: { (element) -> Bool in
            return element === selectedPickable
        }) else {
            preconditionFailure("Could not find index")
        }
        
        // Find index of the one
        let ip = IndexPath(row: indexOfPickable, section: 0)
        table.selectRow(at: ip, animated: false, scrollPosition: .none)
        selectedIndexPath = ip
    }
    
    private func drawDiagonalLineThroughTable() {

        let v = TriangleView(frame: table.frame)
        view.addSubview(v)
        view.sendSubview(toBack: v)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            v.centerXAnchor.constraint(equalTo: table.centerXAnchor),
            v.centerYAnchor.constraint(equalTo: table.centerYAnchor),
            ])
    }
    
    // MARK: Selectors
    
    @objc func dismissView() {
        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
    
    @objc func confirmAndDismiss() {
        if let usersPick = selectedPickable {
            sendBack(pickable: usersPick)
        }

        navigationController?.popViewController(animated: Constant.Animation.pickerVCsShouldAnimateOut)
    }
}

// MARK: - Extensions

// MARK: PickableSender

extension PickerController: PickableSender {
    func sendBack(pickable: T) {
        pickableReceiver?.receive(pickable: pickable)
    }
}

