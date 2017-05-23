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
        boxFrame.clipsToBounds = true
        
        super.init(frame: CGRect(x: 0, y: 0, width: bgFrame.frame.width, height: bgFrame.frame.height))
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        backgroundColor = .yellow

        // header
        if let header = header {
            header.label.text = "Some header"
            header.label.sizeToFit()
            header.frame.origin.x = header.frame.origin.x + Constant.layout.Box.spacingFromSides
            addSubview(header)
        }
        
        // frame
        boxFrame.frame = CGRect(x: Constant.layout.Box.spacingFromSides, y: header?.frame.height ?? 0, width: Constant.layout.Box.Standard.width, height: Constant.layout.Box.Standard.height)
        boxFrame.clipsToBounds = true

        addSubview(boxFrame)
        
        
        
        
        
        // FIXME: - Content
        addSubview(content)
        content.frame = boxFrame.frame
        content.contentStack.drawBackground()
        print("content frame:", content.frame)
        
        // subheader
        if let subheader = subheader {
            addSubview(subheader)
            setSubheaderAnchors(subheader)
        }
        
        if let header = header {
            bringSubview(toFront: header)
        }
        setNeedsLayout()
    }
    
    // Box functions
    
    public func setTitle(_ newText: String) {
        if let header = header {
            header.label.text = newText.uppercased()
            header.label.sizeToFit()
        }
    }
    
    public func setSubHeader(_ newText: String) {
        if let subheader = subheader {
            subheader.label.text = newText.uppercased()
            subheader.clipsToBounds = true
            setSubheaderAnchors(subheader)
        }
    }
    
}

fileprivate extension Box {
    
    func setSubheaderAnchors(_ subheader: BoxSubHeader) {
        subheader.translatesAutoresizingMaskIntoConstraints = false
        subheader.heightAnchor.constraint(equalToConstant: subheader.frame.height).isActive = true
        subheader.widthAnchor.constraint(equalToConstant: subheader.frame.width).isActive = true
        subheader.bottomAnchor.constraint(equalTo: header!.bottomAnchor, constant: 0).isActive = true
        subheader.rightAnchor.constraint(equalTo: boxFrame.rightAnchor, constant: 0).isActive = true
        setNeedsLayout()
        
        /*
         Noe er feil med at når jeg oppdaterer labelen, så er ikke dette det samme som å oppdatere viewen "subheader", siden denne bare inneholder labelen. Jeg må få til en ordentlig setup av disse.. Kanskje viewen skal være like lang som boksen, og så er texten bare alignet til venstre i den? Da holder det å oppdatere teksten, og jeg slipper å aligne boxviewne gang på gang... jeg kan flytte anchoringen inn i boxen.
         */
    }
    
}
