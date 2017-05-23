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
        label.font = UIFont.custom(style: .bold, ofSize: .bigger)
        label.textColor = .darkest
        label.text = "some header"
        label.sizeToFit()
        addSubview(label)
        self.frame = CGRect(x: 0, y: 0, width: Constant.layout.Box.Standard.width, height: label.frame.height)
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
        label.font = UIFont.custom(style: .bold, ofSize: .big)
        label.textColor = UIColor.medium
        label.text = "Some subheader"
        label.sizeToFit()
        label.textAlignment = .right
        addSubview(label)
        self.frame = CGRect(x: 0, y: 0, width: Constant.layout.Box.Standard.width, height: label.frame.height)
        label.frame = self.frame
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Content

public class BoxContent: UIView {
    var contentStack = UIStackView()
}

fileprivate class HistoryBoxContent: BoxContent {
    
    var totalStack = UIStackView()
    var timeStack = UIStackView()
    var personalRecordStack = UIStackView()
    
    var stackFont: UIFont = UIFont.custom(style: .bold, ofSize: .medium)
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        
        // totalStack
        let totalHeader = UILabel()
        totalHeader.font = stackFont
        totalHeader.textColor = .light
        totalHeader.text = "TOTAL"
        totalHeader.sizeToFit()
        
        // - Bottom stack
        let totalText = UILabel()
        totalText.font = stackFont
        totalText.textColor = .light
        totalText.text = "92 x 92"
        totalText.sizeToFit()
//        let totalBottomStack = UIStackView()
//        totalBottomStack.distribution = .equalCentering
//        totalBottomStack.alignment = .center
//        totalBottomStack.axis = .horizontal
        
//        let totalSets = UILabel()
//        let totalReps = UILabel()
//        let xmark = UIImageView(image: UIImage(named: "xmarkBeige"))
        
//        totalSets.text = "15"
//        totalSets.sizeToFit()
//        totalSets.font = stackFont
//        totalSets.textColor = .light
//        
//        totalReps.text = "92"
//        totalReps.sizeToFit()
//        totalReps.textColor = .light
//        totalReps.font = stackFont
        
        // begynner med totalbottom
//        totalBottomStack.addArrangedSubview(totalSets)
//        totalBottomStack.addArrangedSubview(xmark)
//        totalBottomStack.addArrangedSubview(totalReps)
        
        
        //addSubview(totalBottomStack)
        
        totalStack.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        totalStack.addArrangedSubview(totalHeader)
        totalStack.addArrangedSubview(totalText)
        addSubview(totalStack)
        
        totalStack.distribution = .equalCentering
        totalStack.alignment = .center
        totalStack.axis = .vertical
        totalStack.spacing = 10
        totalStack.sizeToFit()
        totalStack.drawBackground()
        
        
//        addSubview(totalSets)
//        print("totalsets: ", totalSets)
//        
//        let test = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
//        test.text = "bam"
//        
//        //addSubview(test) // funker
//        
//        totalBottomStack.addArrangedSubview(test)
//        addSubview(totalBottomStack)
//        
//        totalBottomStack.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
//        totalBottomStack.makeBackground()
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
        background.frame = CGRect(x: 0, y: 0, width: Constant.UI.width - 2*Constant.layout.Box.spacingFromSides, height: Constant.layout.Box.Standard.height)
        
        let shimmerInset = Constant.layout.Box.shimmerInset
        shimmer.backgroundColor = .white
        shimmer.alpha = 0.1
        shimmer.frame = CGRect(x: shimmerInset, y: shimmerInset, width: background.frame.width - 2*shimmerInset, height: background.frame.height - 2*shimmerInset)
        
        addSubview(background)
        addSubview(shimmer)
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
