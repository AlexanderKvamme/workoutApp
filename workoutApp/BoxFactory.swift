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

// MARK: - Box parts

// Headers

public class BoxHeader: UIView {
    public var label = UILabel()
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class StandardBoxHeader: BoxHeader {

    override init() {
        super.init()
        label.font = UIFont.custom(style: .bold, ofSize: .big)
        label.textColor = .darkest
        label.text = "some header"
        label.sizeToFit()
        addSubview(label)
        self.frame = CGRect(x: 0, y: 0, width: Constant.components.Box.Standard.width, height: label.frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Sub Headers

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
        label.text = "Some subheader"
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

// Content

public class BoxContent: UIView {
    var contentStack: ThreeColumnStack!
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Frame

public class BoxFrame: UIView {
    
    var background = UIView()
    var shimmer = UIView()
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class StandardBoxFrame: BoxFrame {

    override init(){
        super.init()
        background.backgroundColor = .primary
        background.frame = CGRect(x: 0, y: 0, width: Constant.UI.width - 2*Constant.components.Box.spacingFromSides, height: Constant.components.Box.Standard.height)
        
        let shimmerInset = Constant.components.Box.shimmerInset
        shimmer.backgroundColor = .white
        shimmer.alpha = 0.1
        shimmer.frame = CGRect(x: shimmerInset, y: shimmerInset, width: background.frame.width - 2*shimmerInset, height: background.frame.height - 2*shimmerInset)
        
        addSubview(background)
        addSubview(shimmer)
        
        print()
        print("I Box boxFactory:")
//        print("- boxFrame:", boxFrame.frame)
        print("- frame:", frame)
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
