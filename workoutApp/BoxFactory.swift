//
//  ModalFactory.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 21/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

/*
    Abstract Factory pattern used to create some of the most used boxes in the app. Maybe not 100% appropriate but interesting to try to use some creational patterns.
 */

public enum BoxType {
    case HistoryBox
    case WorkoutBox
    case SuggestionBox // mulig denne ikke passer inn
    case SelectionBox
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
}

// Suggestion box factory

fileprivate class SuggestionBoxFactory: BoxFactory {
    
    override func makeBoxHeader() -> BoxHeader {
        return StandardBoxHeader()
    }
    
    override func makeBoxSubHeader() -> BoxSubHeader {
        return StandardBoxSubHeader()
    }
    
    override func makeBoxFrame() -> BoxFrame {
        return StandardBoxFrame()
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

// MARK: - Box parts

// MARK: - Box Headers

public class BoxHeader: UIView {
    public var label = UILabel()
    
    init() {
        super.init(frame: CGRect.zero)
        
        label.font = UIFont.custom(style: .bold, ofSize: .big)
        label.textColor = .darkest
        label.text = "header goes here"
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class StandardBoxHeader: BoxHeader {

    override init() {
        super.init()

        label.numberOfLines = 2
        label.sizeToFit()
        addSubview(label)
        frame = CGRect(x: Constant.components.Box.spacingFromSides,
                       y: 0,
                       width: Constant.components.Box.Standard.width,
                       height: label.frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class SelectionBoxHeader: BoxHeader {
    override init() {
        super.init()

        label.font = UIFont.custom(style: .bold, ofSize: .medium)
        label.applyCustomAttributes(.medium)
        
        // temp label to set up boxheader height
        let templabel = label
        templabel.sizeToFit()
        
        label.textAlignment = .center
        
        let selectionBoxFrameWidth = Constant.components.Box.Selection.width - 2*Constant.components.Box.spacingFromSides
        frame = CGRect(x: Constant.components.Box.spacingFromSides,
                       y: 0,
                       width: selectionBoxFrameWidth,
                       height: templabel.frame.height)
        label.frame.size = frame.size
        label.applyCustomAttributes(.more)
        addSubview(label)
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
        self.frame = CGRect(x: 0, y: 0, width: Constant.components.Box.Standard.width, height: label.frame.height)
        label.frame = self.frame
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Box Content

public class BoxContent: UIView {
    var contentStack: ThreeColumnStack?
    var label: UILabel?
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
        contentStack.frame.size = CGSize(width: Constant.components.Box.Standard.width, height: Constant.components.Box.Standard.height)
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

fileprivate class SelectionBoxContent: BoxContent {
    
    init() {
        let contentWidth = Constant.components.Box.Selection.width - 2*Constant.components.Box.spacingFromSides
        
        super.init(frame: CGRect(x: 0, y: 0,
                                 width: contentWidth,
                                 height: Constant.components.Box.Selection.height))
        label = UILabel()
        guard let label = label else {
            print("error in selectionboxcontent with optional label creation")
            return
        }
        
        // label
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

// MARK: - BoxFrames

public class BoxFrame: UIView {
    
    var background = UIView()
    var shimmer = UIView()
    
    init() {
        super.init(frame: CGRect.zero)
//        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        // background properties
        background.backgroundColor = .primary
        
        // shimmer properties
        shimmer.backgroundColor = .white
        shimmer.alpha = 0.1
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class StandardBoxFrame: BoxFrame {

    override init(){
        super.init()
        
        let standardBoxSize = CGSize(width: Constant.UI.width - 2*Constant.components.Box.spacingFromSides,
                                     height: Constant.components.Box.Standard.height)
        // Colored view behind shimmer
        background.frame = CGRect(x: 0,
                                  y: 0,
                                  width: standardBoxSize.width,
                                  height: standardBoxSize.height)
        // Shimmer
        let shimmerInset = Constant.components.Box.shimmerInset
        shimmer.frame = CGRect(x: shimmerInset,
                               y: shimmerInset,
                               width: background.frame.width - 2*shimmerInset,
                               height: background.frame.height - 2*shimmerInset)
        
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
        let boxHeight = Constant.components.Box.Selection.height
        let spacingFromSides = 2*Constant.components.Box.spacingFromSides
        
        let boxSize = CGSize(width: boxWidth-2*spacingFromSides,
                             height: boxHeight)
        
        frame.size = CGSize(width: Constant.UI.width/2 - 2*Constant.components.Box.spacingFromSides,
                            height: Constant.components.Box.Selection.height)
        
        // Colored background
        background.frame.size = CGSize(width: boxSize.width, height: boxSize.height)
        
        // Shimmer
        let shimmerInset = Constant.components.Box.shimmerInset * 2
        shimmer.frame.size = CGSize(width: boxSize.width - shimmerInset,
                                    height: boxSize.height - shimmerInset)
        
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



// The 3 components

//fileprivate class BoxComponent: UIView {
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
