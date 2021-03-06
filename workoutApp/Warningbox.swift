

import Foundation
import UIKit


/// Red box that can be shown in the profile controller with messages such as errors or updates.
class Warningbox: Box {
    
    // MARK: - Properties
    
    var warning: Warning? = nil
    
    // MARK: - Initializers
    
    init(withWarning newWarning: Warning) {
        
        let boxFactory = BoxFactory.makeFactory(type: .WarningBox)
        let boxHeader = boxFactory.makeBoxHeader()
        let boxSubHeader = boxFactory.makeBoxSubHeader()
        let boxFrame = boxFactory.makeBoxFrame()
        let boxContent = boxFactory.makeBoxContent()
        
        super.init(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent)
        setupBoxFrameUsingAutolayout()
        
        self.warning = newWarning
        
        if let message = warning?.message {
            setMessage(message)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func getWarning() -> Warning? {
        return warning
//        if warning != nil { return warning } else { return nil }
    }
    
    /// check if the frame supports autolayout ( only warning box does int he first place), and if so, set it up real nice.
    private func setupBoxFrameUsingAutolayout() {
        
        guard let content = content else { return }
        let contentInsets: CGFloat = 10
        
        // setup boxFrame
        if boxFrame.usesAutoLayout {
            // TODO: So far onlly WarningBoxFrame does this. Will fix this for the rest later.
            boxFrame.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                boxFrame.leftAnchor.constraint(equalTo: leftAnchor),
                boxFrame.topAnchor.constraint(equalTo: topAnchor),
                boxFrame.widthAnchor.constraint(equalToConstant: Constant.UI.width),
                boxFrame.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
                ])
        }
        
        // Setup ContentBox
        if content.usesAutoLayout {
            content.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                content.leftAnchor.constraint(equalTo: boxFrame.shimmer.leftAnchor, constant: contentInsets),
                content.rightAnchor.constraint(equalTo: boxFrame.rightAnchor, constant: -contentInsets),
                content.topAnchor.constraint(equalTo: boxFrame.topAnchor, constant: contentInsets),
                boxFrame.shimmer.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: contentInsets),
                ])
            
            content.clipsToBounds = true
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: boxFrame.topAnchor),
            bottomAnchor.constraint(equalTo: boxFrame.bottomAnchor),
            leftAnchor.constraint(equalTo: boxFrame.leftAnchor),
            rightAnchor.constraint(equalTo: boxFrame.rightAnchor),
            ])
    }
    
    func setMessage(_ message: String) {
        content?.messageLabel?.text = message.uppercased()
    }
    
    func deleteWarning() {
        if let warning = warning {
            DatabaseFacade.delete(warning)
        }
    }
}

