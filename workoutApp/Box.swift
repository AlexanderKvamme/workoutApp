//
//  Box.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 22/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

public class Box: UIView {
    
    public var header: BoxHeader?
    public var subheader: BoxSubHeader?
    public var boxFrame: BoxFrame
    public var content: BoxContent

    public init(header: BoxHeader?, subheader: BoxSubHeader?, bgFrame: BoxFrame, content: BoxContent) {
        self.header = header
        self.subheader = subheader
        self.boxFrame = bgFrame
        self.content = content
        
        super.init(frame: CGRect.zero)
        
        setup()
//        setDebugColors()
    }
    
    convenience init(header: BoxHeader?, subheader: BoxSubHeader?, bgFrame: BoxFrame, content: BoxContent, headerText: String, subheaderText: String) {
        self.init(header: header, subheader: subheader, bgFrame: bgFrame, content: content)
        setTitle(headerText)
        setSubHeader(subheaderText)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setDebugColors() {
        backgroundColor = .red
        if let header = header {
            header.backgroundColor = .green
            header.label.backgroundColor = .yellow
        }
        if let subheader = subheader {
            subheader.backgroundColor = .brown
            subheader.label.backgroundColor = .purple
        }
    }
    
    fileprivate func setup() {
        
        // header
        if let header = header {
            addSubview(header)
        }
        
        // boxFrame
        boxFrame.frame = CGRect(x: Constant.components.Box.spacingFromSides,
                                y: header?.frame.height ?? 0,
                                width: boxFrame.frame.width,
                                height: boxFrame.frame.height)
        
        addSubview(boxFrame)
        
        // content
        content.frame = boxFrame.frame
//        content.backgroundColor = .purple
        print(content.frame)
        addSubview(content)
        
        // header
        if let header = header {
            bringSubview(toFront: header)
        }

        // Calculate the frame
        frame = CGRect(x: 0, y: 0, width: boxFrame.frame.width + 2*Constant.components.Box.spacingFromSides, height: 160)
        
        // subheader
        if let subheader = subheader {
            addSubview(subheader)
//            subheader.sizeToFit()
            subheader.frame.origin = CGPoint(x: Constant.components.Box.spacingFromSides,
                                             y: header!.label.frame.maxY - subheader.frame.height)
            bringSubview(toFront: subheader)
        }
        setNeedsLayout()
    }
    
    override public var intrinsicContentSize: CGSize {
        
        var newHeight = boxFrame.frame.height
        
        if let header = header {
            newHeight += header.frame.height
        }
        
        return CGSize(width: UIViewNoIntrinsicMetric, height: newHeight)
    }
    
    // Box functions
    
    public func setTitle(_ newText: String) {
        
        var totalHeight: CGFloat = 0
        
        guard let header = header else { return }
            header.label.text = newText.uppercased()
            header.label.sizeToFit()
        
        if let subheader = subheader {
            header.label.preferredMaxLayoutWidth = boxFrame.frame.width - subheader.label.frame.width
        }

            header.frame = CGRect(x: header.frame.minX,
                                  y: header.frame.minY,
                                  width: header.frame.width,
                                  height: header.label.frame.height)
            
            totalHeight = header.label.frame.height + boxFrame.frame.height
            
            frame = CGRect(x: 0,
                           y: 0,
                           width: boxFrame.frame.width + 2*Constant.components.Box.spacingFromSides,
                           height: totalHeight)
            clipsToBounds = true
            
            boxFrame.frame.origin.y = header.frame.height
            content.frame.origin.y = header.frame.height
            
            // update Intrinsic content size to fit new height
            invalidateIntrinsicContentSize()
        
        // subheader
        if let subheader = subheader {
            //setSubheaderAnchors(subheader)
            updateSubheaderPosition(subheader)
            
        }
        setNeedsLayout()
    }
    
    private func updateSubheaderPosition(_ subheader: BoxSubHeader) {
        
        guard let header = header else {
            return
        }
        
        subheader.frame.origin = CGPoint(x: subheader.frame.origin.x,
                                         y: header.frame.maxY - subheader.frame.height)
    }
    
    public func setSubHeader(_ newText: String) {
        if let subheader = subheader {
            subheader.label.text = newText.uppercased()
            subheader.label.sizeToFit()
            subheader.label.frame = CGRect(x: subheader.frame.width - subheader.label.frame.width,
                                           y: 0,
                                           width: subheader.label.frame.width,
                                           height: subheader.label.frame.height)
        }
    }
}


