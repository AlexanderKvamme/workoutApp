import UIKit

let HEX_WIDTH = UIScreen.main.bounds.width*0.8
let HEX_TOP_OFFSET = 200.0
let HEX_ORIGIN = CGPoint(x: UIScreen.main.bounds.width*0.2/2, y: HEX_TOP_OFFSET)
let HEX_SIZE = CGSize(width: HEX_WIDTH, height: HEX_WIDTH)
let HEX_FRAME = CGRect(origin: HEX_ORIGIN, size: HEX_SIZE)

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
        return isPresenting ? 1.0 : 0.0
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
        let hex = HexagonalView(frame: HEX_FRAME)
        hex.fillColor = .clear
        containerView.addSubview(hex)
        
        // Start with a zoomed-in hexagon
        hex.transform = CGAffineTransform(scaleX: 10, y: 10)
        
        // Animation durations
        let duration = transitionDuration(using: transitionContext)
        let DURATION_HEX_FILL_SCREEN = duration * 0.1
        
        // Animate color change
        // MARK: STEP 1 - Fade in huge hex
        hex.animateColorChange(to: self.endColor, duration: DURATION_HEX_FILL_SCREEN)
        
        // First animation - scale down with subtle easing
        UIView.animate(
            withDuration: DURATION_HEX_FILL_SCREEN,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                hex.transform = CGAffineTransform(scaleX: 5, y: 5)
            }, completion: { _ in
                fromView.alpha = 0
                toView.alpha = 1
                
                // MARK: STEP 2 - Smooth transition to final state with subtle spring
                UIView.animate(
                    withDuration: duration * 0.6,
                    delay: 0,
                    usingSpringWithDamping: 0.9,  // Very subtle spring (0.9 = minimal bounce)
                    initialSpringVelocity: 0.3,
                    options: .curveEaseInOut,
                    animations: {
                        // Slight overshoot but very subtle
                        hex.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
                    }, completion: { _ in
                        // Final settle animation
                        UIView.animate(
                            withDuration: duration * 0.3,
                            delay: 0,
                            options: .curveEaseOut,
                            animations: {
                                hex.transform = .identity
                            }, completion: { _ in
                                // Clean up and complete the transition
                                hex.removeFromSuperview()
                                if let toViewController = transitionContext.viewController(forKey: .to) {
                                         // If you need to access properties on the destination view controller
                                         // you can do it here without casting the view
                                         // Example: if let hexVC = toViewController as? HexagonViewController { ... }
                                    let tv = toViewController as? HexCompletionScreen
                                    let testView = tv?.hex
                                    testView?.alpha = 1
                                    }
                                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                            }
                        )
                    }
                )
            }
        )
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
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                fromView.alpha = 0
            }, completion: { _ in
                // Complete the transition
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}
