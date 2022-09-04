//
//  ModalFactory.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 21/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

///  Abstract Factory pattern used to create some of the most used boxes in the app. Maybe not 100% appropriate but interesting to try to use some creational patterns.

public enum BoxType {
    case HistoryBox
    case WorkoutBox
    case SuggestionBox
    case SelectionBox
    case WarningBox
    case ExerciseTableCellBox
    case TallExerciseTableCellBox
    case DeletionBox
}

public class BoxFactory {
    public func makeBoxHeader() -> BoxHeader? {
        return nil
    }
    
    public func makeBoxSubHeader() -> BoxSubHeader? {
        return nil
    }
    
    public func makeBoxFrame() -> BoxFrame? {
        return nil
    }
    
    public func makeBoxContent() -> BoxContent? {
        return nil
    }

    // MARK: - makeFactory method
    
    public final class func makeFactory(type: BoxType) -> BoxFactory {
        var factory: BoxFactory
        switch(type) {
        case .HistoryBox:
            factory = HistoryBoxFactory()
        case .WorkoutBox:
            factory = WorkoutBoxFactory()
        case .SuggestionBox:
            factory = SuggestionBoxFactory()
        case .SelectionBox:
            factory = SelectionBoxFactory()
        case .ExerciseTableCellBox:
            factory = ExerciseCellBoxFactory()
        case .TallExerciseTableCellBox:
            factory = TallExerciseCellBoxFactory()
        case .WarningBox:
            factory = WarningBoxFactory()
        case .DeletionBox:
            factory = DeletionBoxFactory()
        }
        return factory
    }
}

// MARK: - Factories

// History box factory
fileprivate class HistoryBoxFactory: BoxFactory {
    
    override func makeBoxHeader() -> BoxHeader {
        return StandardBoxHeader()
    }
    override func makeBoxSubHeader() -> BoxSubHeader {
        return StandardBoxSubHeader()
    }
    override func makeBoxFrame() -> BoxFrame {
        return StandardBoxFrame()
    }
    override func makeBoxContent() -> BoxContent? {
        return HistoryBoxContent()
    }
}

// Workout box factory
fileprivate class WorkoutBoxFactory: BoxFactory {
    
    override func makeBoxHeader() -> BoxHeader {
        return StandardBoxHeader()
    }
    override func makeBoxSubHeader() -> BoxSubHeader {
        return StandardBoxSubHeader()
    }
    override func makeBoxFrame() -> BoxFrame {
        return StandardBoxFrame()
    }
    override func makeBoxContent() -> BoxContent? {
        return WorkoutBoxContent()
    }
}

// Suggestion box factory
fileprivate class SuggestionBoxFactory: BoxFactory {
    
    override func makeBoxHeader() -> BoxHeader? {
        return SuggestionBoxHeader()
    }
    override func makeBoxSubHeader() -> BoxSubHeader? {
        return SuggestionBoxSubHeader()
    }
    override func makeBoxFrame() -> BoxFrame {
        return StandardBoxFrame()
    }
    override func makeBoxContent() -> BoxContent? {
        return nil
    }
}

// Selection Box Factory
fileprivate class SelectionBoxFactory: BoxFactory {
    
    public override func makeBoxHeader() -> BoxHeader? {
        return SelectionBoxHeader()
    }
    public override func makeBoxSubHeader() -> BoxSubHeader? {
        return nil
    }
    public override func makeBoxFrame() -> BoxFrame? {
        return SelectionBoxFrame()
    }
    public override func makeBoxContent() -> BoxContent? {
        return SelectionBoxContent()
    }
}

// Exercise Progress Box Factory
fileprivate class ExerciseCellBoxFactory: BoxFactory {
    
    public override func makeBoxHeader() -> BoxHeader? {
        return ExerciseProgressBoxHeader()
    }
    public override func makeBoxSubHeader() -> BoxSubHeader? {
        return nil
    }
    public override func makeBoxFrame() -> BoxFrame? {
        return ExerciseProgressBoxFrame()
    }
    public override func makeBoxContent() -> BoxContent? {
        return nil
    }
}

/// This is the Box contained in the weighted cells of the ExerciseTable, because they need extra height
fileprivate class TallExerciseCellBoxFactory: BoxFactory {
    
    public override func makeBoxHeader() -> BoxHeader? {
        return ExerciseProgressBoxHeader()
    }
    public override func makeBoxSubHeader() -> BoxSubHeader? {
        return nil
    }
    public override func makeBoxFrame() -> BoxFrame? {
        return TallExerciseProgressBoxFrame()
    }
    public override func makeBoxContent() -> BoxContent? {
        return nil
    }
}

// Warning Box Factory
fileprivate class WarningBoxFactory: BoxFactory {
    
    public override func makeBoxHeader() -> BoxHeader? {
        return nil
    }
    public override func makeBoxSubHeader() -> BoxSubHeader? {
        return nil
    }
    public override func makeBoxFrame() -> BoxFrame? {
        return WarningBoxFrame()
    }
    public override func makeBoxContent() -> BoxContent? {
        return WarningBoxContent()
    }
}

// Deletion Box Factory
fileprivate class DeletionBoxFactory: BoxFactory {
    
    public override func makeBoxHeader() -> BoxHeader? {
        return nil
    }
    public override func makeBoxSubHeader() -> BoxSubHeader? {
        return nil
    }
    public override func makeBoxFrame() -> BoxFrame? {
        return DeletionBoxFrame()
    }
    public override func makeBoxContent() -> BoxContent? {
        return DeletionBoxContent()
    }
}

// MARK: - Box parts

// MARK: Box Headers

/// A large text above over the coloured box to the left.
public class BoxHeader: UIView {
    
    public var boxHeaderLabel = UILabel()
    
    init() {
        super.init(frame: CGRect.zero)
        boxHeaderLabel.font = UIFont.custom(style: .bold, ofSize: .big)
        boxHeaderLabel.textColor = .akDark
        boxHeaderLabel.text = "header goes here"
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class WarningBoxHeader: BoxHeader {
    override init(){
        super.init()
        boxHeaderLabel.font = UIFont.custom(style: .bold, ofSize: .medium)
        boxHeaderLabel.numberOfLines = 1
        boxHeaderLabel.text = "WARNING"
        boxHeaderLabel.sizeToFit()
        addSubview(boxHeaderLabel)
        frame = CGRect(x: Constant.components.box.spacingFromSides, y: 0, width: Constant.components.box.Standard.width, height: boxHeaderLabel.frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class SuggestionBoxHeader: BoxHeader {
    override init() {
        super.init()
        
        boxHeaderLabel.font = UIFont.custom(style: .bold, ofSize: .smallPlus)
        boxHeaderLabel.textAlignment = .center
        boxHeaderLabel.alpha = Constant.alpha.faded
        boxHeaderLabel.numberOfLines = 1
        addSubview(boxHeaderLabel)
        
        translatesAutoresizingMaskIntoConstraints = false
        boxHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            boxHeaderLabel.topAnchor.constraint(equalTo: topAnchor),
            boxHeaderLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            boxHeaderLabel.leftAnchor.constraint(equalTo: leftAnchor),
            boxHeaderLabel.rightAnchor.constraint(equalTo: rightAnchor),
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class StandardBoxHeader: BoxHeader {

    override init() {
        super.init()
        boxHeaderLabel.font = UIFont.custom(style: .bold, ofSize: .mediumPlus)
        boxHeaderLabel.numberOfLines = 2
        boxHeaderLabel.sizeToFit()
        addSubview(boxHeaderLabel)
        frame = CGRect(x: Constant.components.box.spacingFromSides, y: 0, width: Constant.components.box.Standard.width, height: boxHeaderLabel.frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class ExerciseProgressBoxHeader: BoxHeader {
    
    override init() {
        super.init()
        boxHeaderLabel.font = UIFont.custom(style: .bold, ofSize: .medium)
        boxHeaderLabel.numberOfLines = 2
        boxHeaderLabel.sizeToFit()
        addSubview(boxHeaderLabel)
        frame = CGRect(x: Constant.components.box.spacingFromSides, y: 0, width: Constant.components.box.ExerciseProgress.width, height: boxHeaderLabel.frame.height + 8)
    
        boxHeaderLabel.frame = CGRect(x: Constant.components.box.spacingFromSides, y: 0, width: Constant.components.box.ExerciseProgress.width - Constant.components.box.spacingFromSides, height: boxHeaderLabel.frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) haas not been implemented")
    }
}

fileprivate class SelectionBoxHeader: BoxHeader {
    override init() {
        super.init()
        boxHeaderLabel.font = UIFont.custom(style: .bold, ofSize: .medium)
        boxHeaderLabel.applyCustomAttributes(.medium)
        
        // temp label to set up boxheader height
        let templabel = boxHeaderLabel
        templabel.sizeToFit()
        
        boxHeaderLabel.textAlignment = .center
        
        let selectionBoxFrameWidth = Constant.components.box.Selection.width - 2*Constant.components.box.spacingFromSides
        frame = CGRect(x: Constant.components.box.spacingFromSides, y: 0, width: selectionBoxFrameWidth, height: templabel.frame.height)
        boxHeaderLabel.frame.size = frame.size
        boxHeaderLabel.applyCustomAttributes(.more)
        addSubview(boxHeaderLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Box Subheaders

public class BoxSubHeader: UIView {
    
    public var label = UILabel()
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class StandardBoxSubHeader: BoxSubHeader {
    
    override init() {
        super.init()
        label.font = UIFont.custom(style: .bold, ofSize: .medium)
        label.textColor = UIColor.medium
        label.text = "SUBHEADER"
        label.sizeToFit()
        label.textAlignment = .right
        addSubview(label)
        self.frame = CGRect(x: 0, y: 0, width: Constant.components.box.Standard.width, height: label.frame.height)
        label.frame = self.frame
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class SuggestionBoxSubHeader: BoxSubHeader {
    override init() {
        super.init()
        label.font = UIFont.custom(style: .bold, ofSize: .big)
        label.textColor = UIColor.lightest
        label.text = "SUBHEADER"
        label.sizeToFit()
        label.textAlignment = .center
        addSubview(label)
        self.frame = CGRect(x: 0, y: 0, width: Constant.components.box.Standard.width, height: label.frame.height)
        label.frame = self.frame
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Box Content

/// Content it whatever is to be displayed on the actual boxFrame. Any for om text or buttons etc.
public class BoxContent: UIView {
    var xButton: UIButton?
    var contentStack: ThreeColumnStack?
    var label: UILabel?
    var messageLabel: UILabel?
    var usesAutoLayout = false
    
    /// Takes properties from the workout and sets up some stacks of information.
    func setup(usingWorkout workout: Workout) {
        if let cont = self as? WorkoutBoxContent {
            if let firstStack = cont.contentStack?.firstStack {
                firstStack.setTopText("Last")
                firstStack.setBottomText(workout.timeSinceLastPerformence())
            }
            if let secondStack = cont.contentStack?.secondStack {
                secondStack.setTopText("AVG")
                secondStack.setBottomText(workout.getAverageTime())
            }
            if let thirdStack = cont.contentStack?.thirdStack {
                thirdStack.setTopText("Count")
                thirdStack.setBottomText(String(workout.performanceCount))
            }
        }
    }
}

fileprivate class HistoryBoxContent: BoxContent {
    
    var totalStack: TwoRowStack!
    var timeStack: TwoRowStack!
    var personalRecordStack: TwoRowStack!
    
    var stackFont: UIFont = UIFont.custom(style: .bold, ofSize: .medium)
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        
        let totalStack = TwoRowStack(topText: "Total", sets: 13, reps: 92)
        let timeStack = TwoRowStack(topText: "Time", bottomText: "1H")
        let PRStack = TwoRowStack(topText: "PRS", bottomText: "13")
        
        contentStack = ThreeColumnStack(withSubstacks: totalStack, timeStack, PRStack)
        if let contentStack = contentStack {
        // content Stack - Fills entire box and arranges the 3 stacks horzontally
            contentStack.frame.size = CGSize(width: Constant.components.box.Standard.width, height: Constant.components.box.Standard.height)
        contentStack.distribution = .equalCentering
        contentStack.alignment = .center
        contentStack.axis = .horizontal
        contentStack.spacing = 10
        
        addSubview(contentStack)
    
        // Left and right margins
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// WorkoutBox content
fileprivate class WorkoutBoxContent: BoxContent {
    
    var totalStack: TwoRowStack!
    var timeStack: TwoRowStack!
    var personalRecordStack: TwoRowStack!
    
    var stackFont: UIFont = UIFont.custom(style: .bold, ofSize: .medium)
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        
        let leftStack = TwoRowStack(topText: "LAST", bottomText: "X")
        let midStack = TwoRowStack(topText: "AVG", bottomText: "X")
        let rightStack = TwoRowStack(topText: "COUNT", bottomText: "X")
        
        contentStack = ThreeColumnStack(withSubstacks: leftStack, midStack, rightStack)
        if let contentStack = contentStack {
            // content Stack - Fills entire box and arranges the 3 stacks horzontally
            contentStack.frame.size = CGSize(width: Constant.components.box.Standard.width, height: Constant.components.box.Standard.height)
            contentStack.distribution = .equalCentering
            contentStack.alignment = .center
            contentStack.axis = .horizontal
            contentStack.spacing = 10
            
            addSubview(contentStack)
            
            // Left and right margins
            contentStack.isLayoutMarginsRelativeArrangement = true
            contentStack.layoutMargins = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// SelectionBox content

fileprivate class SelectionBoxContent: BoxContent {
    
    init() {
        let contentWidth = Constant.components.box.Selection.width - 2*Constant.components.box.spacingFromSides
        
        super.init(frame: CGRect(x: 0, y: 0, width: contentWidth, height: Constant.components.box.Selection.height))
        label = UILabel()
        guard let label = label else {
            preconditionFailure("error in selectionboxcontent with optional label creation")
        }
        
        // setup label
        label.font = UIFont.custom(style: .bold, ofSize: .big)
        label.textColor = UIColor.lightest
        label.text = "content"
        label.frame = frame
        label.textAlignment = .center
        label.applyCustomAttributes(.more)
        
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class SuggestionBoxContent: BoxContent {
    
    init() {
        super.init(frame: CGRect.zero)
        
        usesAutoLayout = true
        
        // Setup Headerlabel
        label = UILabel(frame: CGRect.zero)
        guard let label = label else { return }
        label.font = UIFont.custom(style: .bold, ofSize: .medium)
        label.textColor = UIColor.lightest
        label.textAlignment = .center
        label.alpha = Constant.alpha.faded
        label.text = "label"
        label.applyCustomAttributes(.more)
        label.sizeToFit()
        addSubview(label)
        
        // Setup message of the suggestion
        messageLabel = UILabel(frame: CGRect.zero)
        guard let messageLabel = messageLabel else { return }
        addSubview(messageLabel)
        
        messageLabel.font = UIFont.custom(style: .bold, ofSize: .big)
        messageLabel.textColor = .light
        messageLabel.numberOfLines = 0
        messageLabel.text = "MessagesLabel".uppercased()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setHeader(_ str: String) {
        label?.text = str
    }
    
    public func setMessage(_ str: String) {
        messageLabel?.text = str
    }
}

fileprivate class WarningBoxContent: BoxContent {
    
    // Initializers
    
    init() {
        super.init(frame: CGRect.zero)
        let topLeftSpacing: CGFloat = 10
        let topRightInsets: CGFloat = 10
        let buttonDiameter: CGFloat = 20
        
        usesAutoLayout = true
        
        // Headerlabel
        label = UILabel(frame: CGRect.zero)
        guard let label = label else { return }
        label.font = UIFont.custom(style: .bold, ofSize: .medium)
        label.textColor = UIColor.lightest
        label.alpha = Constant.alpha.faded
        label.text = "WARNING"
        label.applyCustomAttributes(.more)
        label.sizeToFit()
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: topLeftSpacing),
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: topLeftSpacing),
            ])
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        
        // xButton in the top right
        let xImage = UIImage.xmarkIcon.withRenderingMode(.alwaysTemplate)
        xButton = UIButton()
        guard let xButton = xButton else { return }
        xButton.setImage(xImage, for: .normal)
        xButton.tintColor = .lightest
        xButton.alpha = Constant.alpha.faded
        addSubview(xButton)
        
        // Layout
        xButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            xButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -topRightInsets),
            xButton.topAnchor.constraint(equalTo: topAnchor, constant: topRightInsets),
            xButton.widthAnchor.constraint(equalToConstant: buttonDiameter),
            xButton.heightAnchor.constraint(equalToConstant: buttonDiameter),
            ])
        
        // The message
        messageLabel = UILabel(frame: CGRect.zero)
        guard let messageLabel = messageLabel else { return }
        addSubview(messageLabel)
        
        messageLabel.font = UIFont.custom(style: .bold, ofSize: .big)
        messageLabel.textColor = .akLight
        messageLabel.numberOfLines = 0
        messageLabel.text = "Messages go here".uppercased()
        
        // Message Layout
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: topRightInsets),
            messageLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -topRightInsets),
            messageLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            ])
        messageLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .vertical)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: DeletionBoxContent

fileprivate class DeletionBoxContent: BoxContent {

    init() {
        super.init(frame: CGRect.zero)
        let horizontalInsets: CGFloat = 10
        
        usesAutoLayout = true
        
        // The message
        messageLabel = UILabel(frame: CGRect.zero)
        guard let messageLabel = messageLabel else { return }
        addSubview(messageLabel)
        
        messageLabel.font = UIFont.custom(style: .bold, ofSize: .big)
        messageLabel.textColor = .akLight
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.text = "Message".uppercased()
        messageLabel.applyCustomAttributes(.more)
        
        // Message Layout
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: horizontalInsets),
            messageLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -horizontalInsets),
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            ])
        messageLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .vertical)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - BoxFrames

/// Boxframe is a class that contains a background and a shimmer. Both are inset from the class itself, so that the class can be set to the edges of wherever you want to display it, and it automatically shows insets.
public class BoxFrame: UIView {
    
    var background = UIView()
    var shimmer = UIView()
    var usesAutoLayout = false // Lets Box class set up using auto layout only for the warningBoxFrame, and eventually for all of them
    
    init() {
        super.init(frame: CGRect.zero)
        background.backgroundColor = .white
        background.layer.cornerCurve = .continuous
        background.layer.cornerRadius = 16

        // Setup shimmer properties
        shimmer.backgroundColor = .clear
        shimmer.alpha = 0.1
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class StandardBoxFrame: BoxFrame {

    override init(){
        super.init()
        
        let standardBoxSize = CGSize(width: Constant.UI.width - 2*Constant.components.box.spacingFromSides, height: Constant.components.box.Standard.height)
        // Setup colored view behind shimmer
        background.frame = CGRect(x: 0, y: 0, width: standardBoxSize.width, height: standardBoxSize.height)
        
        // Setup the actual shimmer
        let shimmerInset = Constant.components.box.shimmerInset
        shimmer.frame = CGRect(x: shimmerInset, y: shimmerInset, width: background.frame.width - 2*shimmerInset, height: background.frame.height - 2*shimmerInset)
        
        frame.size = CGSize(width: standardBoxSize.width, height: standardBoxSize.height)
        
        addSubview(background)
        addSubview(shimmer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class SelectionBoxFrame: BoxFrame {
    override init(){
        super.init()
        
        let boxWidth: CGFloat = 140
        let boxHeight = Constant.components.box.Selection.height
        let spacingFromSides = 2*Constant.components.box.spacingFromSides
        
        let boxSize = CGSize(width: boxWidth-2*spacingFromSides, height: boxHeight)
        frame.size = CGSize(width: Constant.UI.width/2 - 2*Constant.components.box.spacingFromSides, height: Constant.components.box.Selection.height)
        
        // Colored background
        background.frame.size = CGSize(width: boxSize.width, height: boxSize.height)
        
        // Shimmer
        let shimmerInset = Constant.components.box.shimmerInset * 2
        shimmer.frame.size = CGSize(width: boxSize.width - shimmerInset, height: boxSize.height - shimmerInset)
        
        // Positioning
        center.y = center.y + 3 // spacing between this boxFrame and its selectionBoxHeaders
        shimmer.center = center
        background.center = center
        
        addSubview(background)
        addSubview(shimmer)
        
        // Add a button to be placed over the BoxFrame, to allow user input
        let button = UIButton(frame: frame)
        addSubview(button)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class DeletionBoxFrame: BoxFrame {
    
    override init(){
        super.init()
        
        usesAutoLayout = true // Lets Box class get set up using auto layout only for the warningBoxFrame, and eventually for all of them
        
        // Colored view behind shimmer
        background.frame = CGRect.zero
        background.backgroundColor = .secondary
        
        // Shimmer
        let backgroundInset: CGFloat = 5
        
        shimmer.frame = CGRect.zero
        frame.size = CGSize.zero
        
        addSubview(background)
        addSubview(shimmer)
        bringSubview(toFront: shimmer)
        
        // Set up background and shimmer to fill frame of the boxFrame, but with insets
        translatesAutoresizingMaskIntoConstraints = false
        shimmer.translatesAutoresizingMaskIntoConstraints = false
        background.translatesAutoresizingMaskIntoConstraints = false
        
        // Background
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: topAnchor, constant: backgroundInset),
            background.leftAnchor.constraint(equalTo: leftAnchor, constant: backgroundInset),
            background.rightAnchor.constraint(equalTo: rightAnchor, constant: -backgroundInset),
            background.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -backgroundInset),
            ])
        
        // Shimmer
        NSLayoutConstraint.activate([
            shimmer.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -backgroundInset),
            shimmer.topAnchor.constraint(equalTo: background.topAnchor, constant: backgroundInset),
            shimmer.leftAnchor.constraint(equalTo: background.leftAnchor, constant: backgroundInset),
            shimmer.rightAnchor.constraint(equalTo: background.rightAnchor, constant: -backgroundInset),
            ])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The long and yellow/orange box used to hold a collection of Lifts
fileprivate class ExerciseProgressBoxFrame: BoxFrame {
    
    override init(){
        super.init()
        
        let standardBoxSize = CGSize(width: Constant.UI.width - 2*Constant.components.box.spacingFromSides, height: Constant.components.box.ExerciseProgress.height)
        // Colored view behind shimmer
        background.frame = CGRect(x: 0, y: 0, width: standardBoxSize.width, height: standardBoxSize.height)
        // Shimmer
        let shimmerInset = Constant.components.box.shimmerInset
        shimmer.frame = CGRect(x: shimmerInset, y: shimmerInset, width: background.frame.width - 2*shimmerInset, height: background.frame.height - 2*shimmerInset)
        
        frame.size = CGSize(width: standardBoxSize.width, height: standardBoxSize.height)
        
        addSubview(background)
        addSubview(shimmer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class TallExerciseProgressBoxFrame: BoxFrame {
    
    override init(){
        super.init()
        
        let tallBoxSize = CGSize(width: Constant.UI.width - 2*Constant.components.box.spacingFromSides, height: Constant.components.box.TallExerciseProgress.height)
        // Colored view behind shimmer
        background.frame = CGRect(x: 0, y: 0, width: tallBoxSize.width, height: tallBoxSize.height)
        // Shimmer
        let shimmerInset = Constant.components.box.shimmerInset
        shimmer.frame = CGRect(x: shimmerInset, y: shimmerInset, width: background.frame.width - 2*shimmerInset, height: background.frame.height - 2*shimmerInset)
        
        frame.size = CGSize(width: tallBoxSize.width, height:  tallBoxSize.height)
        
        addSubview(background)
        addSubview(shimmer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class WarningBoxFrame: BoxFrame {
    override init(){
        super.init()
        
        usesAutoLayout = true // Lets Box class get set up using auto layout only for the warningBoxFrame, and eventually for all of them
        
        // Colored view behind shimmer
        background.frame = CGRect.zero
        background.backgroundColor = .secondary
        
        // Shimmer
        let backgroundInset: CGFloat = 5
        
        shimmer.frame = CGRect.zero
        frame.size = CGSize.zero
        
        addSubview(background)
        addSubview(shimmer)
        bringSubview(toFront: shimmer)
        
        // Set up background and shimmer to fill frame of the boxFrame, but with insets
        translatesAutoresizingMaskIntoConstraints = false // the class itself
        background.translatesAutoresizingMaskIntoConstraints = false
        shimmer.translatesAutoresizingMaskIntoConstraints = false
        
        // Background
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: topAnchor, constant: backgroundInset),
            background.leftAnchor.constraint(equalTo: leftAnchor, constant: backgroundInset),
            background.rightAnchor.constraint(equalTo: rightAnchor, constant: -backgroundInset),
            background.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -backgroundInset),
            ])
        
        // Shimmer
        NSLayoutConstraint.activate([
            shimmer.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -backgroundInset),
            shimmer.topAnchor.constraint(equalTo: background.topAnchor, constant: backgroundInset),
            shimmer.leftAnchor.constraint(equalTo: background.leftAnchor, constant: backgroundInset),
            shimmer.rightAnchor.constraint(equalTo: background.rightAnchor, constant: -backgroundInset),
            ])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

