import UIKit
import AKKIT

class TimerAlertViewController: UIViewController {
    
    // MARK: - Properties
    let dropsize = 100.0
    let DROP_DURATION = 0.2
    let GROW_DURATION = 0.5
    private let circleView = UIView()
    private var initialCircleSize: CGFloat = 0
    private var finalCircleSize: CGFloat = UIScreen.main.bounds.width * 3
    private var initialPosition = CGPoint.zero
    
    // Stack view to hold all animated text views
    private let textStackView = UIStackView()
    
    // Animated text views
    private let animatedTitleView = AnimatedTextView(
        text: "LETS",
        font: AKFont.gilroy(.black, 80),
        color: .white
    )
    
    private let animatedTitleView2 = AnimatedTextView(
        text: "FRIGGEN",
        font: AKFont.gilroy(.black, 80),
        color: .white
    )
    
    private let animatedTitleView3 = AnimatedTextView(
        text: "GO!",
        font: AKFont.gilroy(.black, 80),
        color: .white
    )
    
    // MARK: - Initializers
    init(startPosition: CGPoint) {
        self.initialPosition = startPosition
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateCircle()
        
        // Delay animations by 0.5 seconds after the circle animation starts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            guard let self = self else { return }
            self.animateTextSequentially()
        }
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        view.backgroundColor = .clear
        
        // Setup circle view
        circleView.backgroundColor = .akGreen
        circleView.backgroundColor = .black
        circleView.layer.cornerRadius = initialCircleSize / 2
        circleView.frame = CGRect(
            x: initialPosition.x - initialCircleSize / 2,
            y: initialPosition.y - initialCircleSize / 2,
            width: initialCircleSize,
            height: initialCircleSize
        )
        view.addSubview(circleView)
        
        // Configure stack view
        textStackView.axis = .vertical
        textStackView.alignment = .center
        textStackView.distribution = .equalSpacing
        textStackView.spacing = 0
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        
        animatedTitleView.enableRandomColorFlash()
        // Add animated text views to stack view
        textStackView.addArrangedSubview(animatedTitleView)
        textStackView.addArrangedSubview(animatedTitleView2)
        textStackView.addArrangedSubview(animatedTitleView3)
        
        // Initially hide all text views
        animatedTitleView.alpha = 0
        animatedTitleView2.alpha = 0
        animatedTitleView3.alpha = 0
        
        view.addSubview(textStackView)
        
        // Position the stack view in the center of the screen
        textStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().inset(40)
        }
        
        // Add tap gesture to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Animation Methods
    private func animateCircle() {
        // First animation: Small growth and drop
        UIView.animate(withDuration: DROP_DURATION, delay: 0, options: .curveEaseIn, animations: {
            self.circleView.frame = CGRect(
                x: Double(UIScreen.main.bounds.width/2 - self.dropsize/2),
                y: Double(UIScreen.main.bounds.height),
                width: self.dropsize,
                height: self.dropsize
            )
            self.circleView.layer.cornerRadius = self.dropsize/2
        }, completion: { _ in
            // Second animation: Dramatic growth filling the screen
            UIView.animate(withDuration: self.GROW_DURATION, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                let newSize = self.finalCircleSize
                self.circleView.frame = CGRect(
                    x: self.view.center.x - newSize/2,
                    y: self.view.center.y - newSize/2,
                    width: newSize,
                    height: newSize
                )
                self.circleView.layer.cornerRadius = newSize/2
            })
        })
    }
    
    private func animateTextSequentially() {
        let test = 0.1
        // First text animation
        UIView.animate(withDuration: test, animations: {
            self.animatedTitleView.alpha = 1.0
        }, completion: { _ in
            self.animatedTitleView.animate()
            
            // Second text animation after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + test) {
                UIView.animate(withDuration: test, animations: {
                    self.animatedTitleView2.alpha = 1.0
                }, completion: { _ in
                    self.animatedTitleView2.animate()
                    
                    // Third text animation after another delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + test) {
                        UIView.animate(withDuration: test, animations: {
                            self.animatedTitleView3.alpha = 1.0
                        }, completion: { _ in
                            self.animatedTitleView3.animate()
                        })
                    }
                })
            }
        })
    }
    
    @objc private func handleTap() {
        // Animate dismissal
        UIView.animate(withDuration: 0.4, animations: {
            self.animatedTitleView.alpha = 0
            self.animatedTitleView2.alpha = 0
            self.animatedTitleView3.alpha = 0
            self.circleView.alpha = 0
        }, completion: { _ in
            self.dismiss(animated: false)
        })
    }
}

// MARK: - Extension for ImprovWorkoutController
extension ImprovWorkoutController {
    
    // Update your alertDidTrigger method to use the new TimerAlertViewController
    func alertDidTrigger() {
        print("⏰⏰⏰⏰⏰⏰⏰⏰⏰⏰")
        
        // Get the center point of the timer view in the main view's coordinate system
        let timerCenter = CGPoint(x: UIScreen.main.bounds.width/2, y: 0 + UIScreen.main.bounds.height/3)
        
        // Create and present the timer alert view controller
        let timerAlertVC = TimerAlertViewController(startPosition: timerCenter)
        present(timerAlertVC, animated: false)
    }
    
    // Optional: Add a method to handle timer completion in case you want to call it from elsewhere
    func showTimerAlert() {
        alertDidTrigger()
    }
}
