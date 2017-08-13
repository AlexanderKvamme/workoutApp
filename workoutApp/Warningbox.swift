

import Foundation
import UIKit

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
        if warning != nil { return warning} else { return nil }
    }
    
    private func setupBoxFrameUsingAutolayout() {
        // check if the frame supports autolayout ( only warning box does int he first place), and if so, set i up real nice.
        let contentInsets: CGFloat = 10
        
        guard let content = content else { return }
        
        // setup boxFrame
        if boxFrame.usesAutoLayout { // har nå kun WarningBoxFrame - Senere vil jeg sette alle opp med autolayout
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

