//
//  HexTransitionAnimator.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 04/05/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//
import UIKit


// MARK: - HexTransitionAnimator
class HexTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let isPresenting: Bool
    private let originFrame: CGRect
    
    init(isPresenting: Bool, originFrame: CGRect) {
        self.isPresenting = isPresenting
        self.originFrame = originFrame
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 3.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        
        if isPresenting {
            // Presenting animation
            guard let toView = transitionContext.view(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
            }
            
            containerView.addSubview(toView)
            toView.alpha = 0
            
            // Create a hexagon that will animate from the origin to the center
            let transitionHex = UIView()
            transitionHex.backgroundColor = .cyan // Start with cyan
            containerView.addSubview(transitionHex)
            
            // Create hexagon shape
            let hexLayer = CAShapeLayer()
            let hexPath = HexagonPathCreator.createHexagonPath(in: originFrame)
            hexLayer.path = hexPath.cgPath
            transitionHex.layer.mask = hexLayer
            
            // Initial position is the origin frame
            transitionHex.frame = originFrame
            
            // Final position is full screen
            let finalFrame = CGRect(x: -50, y: -50,
                                   width: containerView.bounds.width + 100,
                                   height: containerView.bounds.height + 100)
            
            // Animate the hex expanding to fill the screen
            UIView.animate(withDuration: transitionDuration(using: transitionContext) * 0.5, animations: {
                transitionHex.frame = finalFrame
                transitionHex.backgroundColor = .green // Transition to green
                
                // Update the mask to match the new size
                hexLayer.path = HexagonPathCreator.createHexagonPath(in: CGRect(origin: .zero, size: finalFrame.size)).cgPath
                
            }, completion: { _ in
                // Fade in the destination view
                UIView.animate(withDuration: self.transitionDuration(using: transitionContext) * 0.5, animations: {
                    toView.alpha = 1
                    transitionHex.alpha = 0
                }, completion: { _ in
                    transitionHex.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
            })
            
        } else {
            // Dismissing animation
            guard let fromView = transitionContext.view(forKey: .from),
                  let toView = transitionContext.view(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
            }
            
            containerView.insertSubview(toView, belowSubview: fromView)
            
            // Create a hexagon that will animate from center to the origin
            let transitionHex = UIView()
            transitionHex.backgroundColor = .green
            containerView.addSubview(transitionHex)
            
            // Get the center hex from the HexCompletionScreen
            let centerHexFrame = (fromVC as? HexCompletionScreen)?.centerHexView.frame ?? CGRect(x: containerView.bounds.midX - 100, y: containerView.bounds.midY - 100, width: 200, height: 200)
            
            // Create hexagon shape
            let hexLayer = CAShapeLayer()
            let hexPath = HexagonPathCreator.createHexagonPath(in: centerHexFrame)
            hexLayer.path = hexPath.cgPath
            transitionHex.layer.mask = hexLayer
            
            // Initial position is the center frame
            transitionHex.frame = centerHexFrame
            
            // Fade out the source view
            UIView.animate(withDuration: transitionDuration(using: transitionContext) * 0.5, animations: {
                fromView.alpha = 0
                transitionHex.alpha = 1
            }, completion: { _ in
                // Animate the hex shrinking to the origin
                UIView.animate(withDuration: self.transitionDuration(using: transitionContext) * 0.5, animations: {
                    transitionHex.frame = self.originFrame
                    transitionHex.backgroundColor = .cyan // Transition back to cyan
                    
                    // Update the mask to match the new size
                    hexLayer.path = HexagonPathCreator.createHexagonPath(in: CGRect(origin: .zero, size: self.originFrame.size)).cgPath
                    
                }, completion: { _ in
                    transitionHex.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
            })
        }
    }
}

