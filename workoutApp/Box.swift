

import Foundation
import UIKit

// The Box is used to receive parts from the box factory, and then puts the components together based on which parts it receives.s
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
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func setup() {
        var totalHeight: CGFloat = 0
         
        // BoxFrame
        boxFrame.frame.origin = CGPoint(x: Constant.components.box.spacingFromSides, y: header?.frame.height ?? 0)
        addSubview(boxFrame)
        
        // Content
        if let content = content {
            content.frame = boxFrame.frame
            addSubview(content)
        }
        
        // Header
        if let header = header {
            addSubview(header)
            bringSubviewToFront(header)
            totalHeight += header.frame.height
        }
        
        // Calculate the frame
        totalHeight += boxFrame.frame.height
        frame = CGRect(x: 0, y: 0, width: boxFrame.frame.width + 2*Constant.components.box.spacingFromSides, height: totalHeight)
        
        // Subheader
        if let subheader = subheader {
            addSubview(subheader)
            subheader.frame.origin = CGPoint(x: Constant.components.box.spacingFromSides, y: header!.boxHeaderLabel.frame.maxY - subheader.frame.height)
            bringSubviewToFront(subheader)
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
        return CGSize(width: UIView.noIntrinsicMetric, height: newHeight)
    }
    
    // MARK: Box methods
    
    public func setTitle(_ newText: String) {
        var totalHeight: CGFloat = 0
        
        guard let header = header else { return }
        
        // Adjust width if theres a subheader to avoid overlapping
        if let subheader = subheader {
            header.boxHeaderLabel.preferredMaxLayoutWidth = boxFrame.frame.width - subheader.label.frame.width
        } else {
            header.boxHeaderLabel.text = newText.uppercased()
            return
        }
        
        header.boxHeaderLabel.text = newText.uppercased()
        header.boxHeaderLabel.sizeToFit()
        
        header.frame = CGRect(x: header.frame.minX + 4, y: header.frame.minY, width: header.frame.width, height: header.boxHeaderLabel.frame.height+8)
        
        totalHeight = header.boxHeaderLabel.frame.height + boxFrame.frame.height
        
        frame = CGRect(x: 0, y: 0, width: boxFrame.frame.width + 2*Constant.components.box.spacingFromSides, height: totalHeight)
        
        boxFrame.frame.origin.y = header.frame.height
        content?.frame.origin.y = header.frame.height
        button.frame = boxFrame.frame
        
        // Update Intrinsic content size to fit new height
        invalidateIntrinsicContentSize()
        
        // Subheader
        if let subheader = subheader {
            updateSubheaderPosition(subheader)
        }
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
        
        guard let subheader = subheader else {
            return
        }
        
        subheader.label.text = newText.uppercased()
        subheader.label.sizeToFit()
        subheader.label.frame = CGRect(x: subheader.frame.width - subheader.label.frame.width, y: 0, width: subheader.label.frame.width, height: subheader.label.frame.height)
    }
}

// MARK: - Methods for debugging

extension Box {
    
    /// Set colors and alpha for easier debugging
    public func setDebugColors() { }
}

