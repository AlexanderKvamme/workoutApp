import UIKit

// MARK: - HexTransitionAnimator
class HexTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let isPresenting: Bool
    private let originFrame: CGRect
    private let startColor: UIColor
    private let endColor: UIColor
    
    init(isPresenting: Bool,
         originFrame: CGRect,
         startColor: UIColor = .black,
         endColor: UIColor = .black) {
        self.isPresenting = isPresenting
        self.originFrame = originFrame
        self.startColor = startColor
        self.endColor = endColor
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
            
            // Make a big hex that fills entire screen
            let transitionHex = HexagonalView(frame: UIScreen.main.bounds)
            transitionHex.fillColor = startColor
            containerView.addSubview(transitionHex)
            
            // Start with a zoomed-in container
            containerView.transform = CGAffineTransform(scaleX: 10, y: 10)
            
            // Animate to normal size
            UIView.animate(withDuration: transitionDuration(using: transitionContext) * 0.5, animations: {
                containerView.transform = .identity
                transitionHex.animateColorChange(to: self.endColor, duration: self.transitionDuration(using: transitionContext) * 0.3)
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
            let transitionHex = HexagonalView(frame: UIScreen.main.bounds)
            transitionHex.fillColor = endColor
            containerView.addSubview(transitionHex)
            
            // Fade out the source view
            UIView.animate(withDuration: transitionDuration(using: transitionContext) * 0.5, animations: {
                fromView.alpha = 0
            }, completion: { _ in
                // Animate zooming out
                containerView.transform = .identity
                UIView.animate(withDuration: self.transitionDuration(using: transitionContext) * 0.5, animations: {
                    containerView.transform = CGAffineTransform(scaleX: 10, y: 10)
                    transitionHex.animateColorChange(to: self.startColor, duration: self.transitionDuration(using: transitionContext) * 0.3)
                }, completion: { _ in
                    transitionHex.removeFromSuperview()
                    containerView.transform = .identity
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
            })
        }
    }
}
