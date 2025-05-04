import UIKit

// MARK: - HexTransitionAnimator
class HexTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let isPresenting: Bool
    private let originFrame: CGRect
    private let startColor: UIColor
    private let endColor: UIColor
    
    init(isPresenting: Bool,
         originFrame: CGRect,
         startColor: UIColor = .red,
         endColor: UIColor = .black) {
        self.isPresenting = isPresenting
        self.originFrame = originFrame
        self.startColor = startColor
        self.endColor = endColor
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isPresenting ? 0.3 : 0.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            performPresentingAnimation(using: transitionContext)
        } else {
            performDismissingAnimation(using: transitionContext)
        }
    }
    
    private func performPresentingAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to),
              let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        
        // Add the destination view
        containerView.addSubview(toView)
        toView.alpha = 0
        
        // Create the hexagon view
        let hex = HexagonalView(frame: UIScreen.main.bounds)
        hex.fillColor = .clear
        containerView.addSubview(hex)
        
        // Start with a zoomed-in hexagon
        hex.transform = CGAffineTransform(scaleX: 10, y: 10)
        
        // Animation durations
        let duration = transitionDuration(using: transitionContext)
        let DURATION_HEX_FILL_SCREEN = duration * 0.1
        let transformDuration = (duration - DURATION_HEX_FILL_SCREEN)
        
        // Animate color change
        // MARK: STEP 1 - Fade in huge hex
        hex.animateColorChange(to: self.endColor, duration: DURATION_HEX_FILL_SCREEN)
        UIView.animate(
            withDuration: DURATION_HEX_FILL_SCREEN,
            animations: {
                hex.transform = CGAffineTransform(scaleX: 5, y: 5)
            }, completion: { _ in
                fromView.alpha = 0
                toView.alpha = 1
                
            // MARK: STEP 2 -
            UIView.animate(withDuration: duration * 0.3, animations: {
                hex.transform = .identity
                toView.alpha = 1
//                hex.alpha = 0
            }, completion: { _ in
                // Clean up and complete the transition
                hex.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        })
    }
    
    private func performDismissingAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        
        // Make sure the destination view is behind the source view
        containerView.insertSubview(toView, belowSubview: fromView)
        
        // Make sure the destination view is fully visible
        toView.alpha = 1
        
        // Simple fade out animation for the source view
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView.alpha = 0
        }, completion: { _ in
            // Complete the transition
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
