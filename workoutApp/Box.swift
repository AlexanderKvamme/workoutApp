

import Foundation
import UIKit

public class Box: UIView {
    
    // MARK: - Properties
    
    public var header: BoxHeader?
    public var subheader: BoxSubHeader?
    public var boxFrame: BoxFrame
    public var content: BoxContent?
    public var button: UIButton // All boxes gets a invisible button to allow for input
    
    // MARK: - Initializer
    
    public init(header: BoxHeader?, subheader: BoxSubHeader?, bgFrame: BoxFrame, content: BoxContent?) {
        self.header = header
        self.subheader = subheader
        self.boxFrame = bgFrame
        self.content = content
        self.button = UIButton()
        
        super.init(frame: CGRect.zero)
        setup()
        // setDebugColors()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    fileprivate func setup() {
        var totalHeight: CGFloat = 0
         
        // BoxFrame
        boxFrame.frame.origin = CGPoint(x: Constant.components.Box.spacingFromSides, y: header?.frame.height ?? 0)
        addSubview(boxFrame)
        
        // Content
        if let content = content {
            content.frame = boxFrame.frame
            addSubview(content)
        }
        
        // Header
        if let header = header {
            addSubview(header)
            bringSubview(toFront: header)
            totalHeight += header.frame.height
        }
        
        // Calculate the frame
        totalHeight += boxFrame.frame.height
        frame = CGRect(x: 0, y: 0,
                       width: boxFrame.frame.width + 2*Constant.components.Box.spacingFromSides,
                       height: totalHeight)
        
        // Subheader
        if let subheader = subheader {
            addSubview(subheader)
            subheader.frame.origin = CGPoint(x: Constant.components.Box.spacingFromSides,
                                             y: header!.label.frame.maxY - subheader.frame.height)
            bringSubview(toFront: subheader)
        }
        
        // Invisible button
        button.frame = boxFrame.frame
        addSubview(button)
        
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
    
    // FIXME: - Refactor update of gui to a separate function and have setTitle() call it
    
    public func setTitle(_ newText: String) {
        var totalHeight: CGFloat = 0
        
        guard let header = header else { return }
        
        // only adjust width if theres a subheader to avoid overlapping
        if let subheader = subheader {
            header.label.preferredMaxLayoutWidth = boxFrame.frame.width - subheader.label.frame.width
        } else {
            header.label.text = newText.uppercased()
            return
        }
        
        header.label.text = newText.uppercased()
        header.label.sizeToFit()
        
        header.frame = CGRect(x: header.frame.minX,
                              y: header.frame.minY,
                              width: header.frame.width,
                              height: header.label.frame.height)
        
        totalHeight = header.label.frame.height + boxFrame.frame.height
        
        frame = CGRect(x: 0,
                       y: 0,
                       width: boxFrame.frame.width + 2*Constant.components.Box.spacingFromSides,
                       height: totalHeight)
        
        boxFrame.frame.origin.y = header.frame.height
        content?.frame.origin.y = header.frame.height
        button.frame = boxFrame.frame
        
        // update Intrinsic content size to fit new height
        invalidateIntrinsicContentSize()
        
        // subheader
        if let subheader = subheader { updateSubheaderPosition(subheader) }
        setNeedsLayout()
    }
    
    public func setContentLabel(_ string: String) {
        guard let content = content else { return }
        guard let label = content.label else { return }
        
        label.text = string.uppercased()
    }
    
    private func updateSubheaderPosition(_ subheader: BoxSubHeader) {
        guard let header = header else { return }
        
        subheader.frame.origin = CGPoint(x: subheader.frame.origin.x, y: header.frame.maxY - subheader.frame.height)
    }
    
    /// Sets new text and updates position
    public func setSubHeader(_ newText: String) {
        if let subheader = subheader {
            subheader.label.text = newText.uppercased()
            subheader.label.sizeToFit()
            subheader.label.frame = CGRect(x: subheader.frame.width - subheader.label.frame.width, y: 0, width: subheader.label.frame.width, height: subheader.label.frame.height)
        }
    }
}

// MARK: - Methods for debugging

extension Box {
    
    public func setDebugColors() {
        button.backgroundColor = .blue
        button.alpha = 0.5
        backgroundColor = .red
        alpha = 0.8
        
        if let header = header {
            header.backgroundColor = .green
            header.label.backgroundColor = .yellow
        }
        if let subheader = subheader {
            subheader.backgroundColor = .brown
            subheader.label.backgroundColor = .purple
        }
        boxFrame.backgroundColor = .green
        boxFrame.alpha = 0.5
    }
}

