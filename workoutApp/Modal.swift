import UIKit

protocol isModal {
    func show(animated:Bool)
    func dismiss(animated:Bool)
    var backgroundView:UIView {get}
    var containerView:UIView {get set}
}

extension isModal where Self: UIView {
    
    /// Shows the moda
    func show(animated:Bool){
        self.backgroundView.alpha = 0
        self.containerView.center = CGPoint(x: self.center.x, y: self.frame.height + self.containerView.frame.height/2)
        UIApplication.shared.delegate?.window??.rootViewController?.view.addSubview(self)
        if animated {
//            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 1
//            })
//            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 1, options: UIView.AnimationOptions(rawValue: 0), animations: {
//                self.containerView.center  = self.center
//            }, completion: nil)
            
//            UIView.animate(withDuration: 0.0) {
                self.containerView.center  = self.center
//            }
        } else {
            self.backgroundView.alpha = 1
            self.containerView.center  = self.center
        }
    }
    
    func dismiss(animated:Bool){
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 0
            }, completion: nil)
            
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: UIView.AnimationOptions(rawValue: 0), animations: {
                self.containerView.center = CGPoint(x: self.center.x, y: self.frame.height + self.containerView.frame.height/2)
            }, completion: { (completed) in
                self.removeFromSuperview()
            })
        } else {
            self.removeFromSuperview()
        }
    }
}

