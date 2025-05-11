import UIKit

class StarRatingView: UIView {
    
    // MARK: - Properties
    
    private let starColor = UIColor(hexString: "#FFA500") // Orange color
    private var stars: [StarView] = []
    
    // Customizable properties
    var starSize: CGFloat = 30 {
        didSet {
            updateLayout()
        }
    }
    
    var spacing: CGFloat = 8 {
        didSet {
            updateLayout()
        }
    }
    
    var rating: Int = 0 {
        didSet {
            updateStars()
        }
    }
    
    var maxRating: Int = 5 {
        didSet {
            setupStars()
            updateLayout()
        }
    }
    
    var cornerRadius: CGFloat = 6.0 {
        didSet {
            stars.forEach { $0.cornerRadius = cornerRadius }
        }
    }
    
    // Animation properties
    var animationDuration: TimeInterval = 0.3
    var animationDelay: TimeInterval = 0.1
    var animationSpringDamping: CGFloat = 0.6
    var animationInitialVelocity: CGFloat = 0.8
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .clear
        setupStars()
    }
    
    private func setupStars() {
        // Remove existing stars
        stars.forEach { $0.removeFromSuperview() }
        stars.removeAll()
        
        // Create new stars
        for _ in 0..<maxRating {
            let star = StarView(frame: .zero)
            star.cornerRadius = cornerRadius
            star.alpha = 0 // Start invisible for animation
            stars.append(star)
            addSubview(star)
        }
        
        updateLayout()
    }
    
    private func updateLayout() {
        // Calculate available width and adjust star size if needed
        let availableWidth = bounds.width
        let totalStarsWidth = CGFloat(maxRating) * starSize
        let totalSpacingWidth = CGFloat(maxRating - 1) * spacing
        
        var actualStarSize = starSize
        var actualSpacing = spacing
        
        // If stars don't fit, adjust their size and spacing
        if totalStarsWidth + totalSpacingWidth > availableWidth {
            // Calculate the maximum possible star size
            let maxPossibleStarSize = (availableWidth - totalSpacingWidth) / CGFloat(maxRating)
            
            if maxPossibleStarSize > 0 {
                actualStarSize = maxPossibleStarSize
            } else {
                // If even with minimum spacing stars don't fit, reduce spacing too
                actualStarSize = availableWidth / CGFloat(maxRating * 2 - 1)
                actualSpacing = actualStarSize
            }
        }
        
        // Calculate the total width of all stars and spacing
        let totalWidth = CGFloat(maxRating) * actualStarSize + CGFloat(maxRating - 1) * actualSpacing
        
        // Calculate the starting X position to center the stars
        let startX = (bounds.width - totalWidth) / 2
        
        // Position each star
        for (index, star) in stars.enumerated() {
            let xPosition = startX + CGFloat(index) * (actualStarSize + actualSpacing)
            star.frame = CGRect(
                x: xPosition,
                y: (bounds.height - actualStarSize) / 2, // Center vertically
                width: actualStarSize,
                height: actualStarSize
            )
        }
    }
    
    // MARK: - Public Methods
    
    func animateIn(completion: (() -> Void)? = nil) {
        // Reset stars to initial state
        stars.forEach { star in
            star.alpha = 0
            star.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).translatedBy(x: 0, y: 20)
        }
        
        // Animate each star with a delay
        for (index, star) in stars.enumerated() {
            UIView.animate(
                withDuration: animationDuration,
                delay: animationDelay * Double(index),
                usingSpringWithDamping: animationSpringDamping,
                initialSpringVelocity: animationInitialVelocity,
                options: [],
                animations: {
                    star.alpha = 1
                    star.transform = .identity
                },
                completion: { _ in
                    if index == self.stars.count - 1 {
                        completion?()
                    }
                }
            )
        }
    }
    
    func setRating(_ rating: Int, animated: Bool = false) {
        self.rating = min(max(rating, 0), maxRating)
        
        if animated {
            updateStarsWithAnimation()
        } else {
            updateStars()
        }
    }
    
    // MARK: - Private Methods
    
    private func updateStars() {
        for (index, star) in stars.enumerated() {
            star.alpha = index < rating ? 1.0 : 0.3
        }
    }
    
    private func updateStarsWithAnimation() {
        // Store current transforms to avoid resetting
        let currentTransforms = stars.map { $0.transform }
        
        for (index, star) in stars.enumerated() {
            // Set the target alpha
            let targetAlpha = index < self.rating ? 1.0 : 0.3
            
            // Only animate stars that are changing
            if (targetAlpha > 0.5 && star.alpha < 0.5) || (targetAlpha < 0.5 && star.alpha > 0.5) {
                // For stars becoming active, add bounce effect
                if targetAlpha > 0.5 {
                    UIView.animate(
                        withDuration: animationDuration,
                        delay: animationDelay * Double(index),
                        options: [.curveEaseInOut],
                        animations: {
                            star.alpha = targetAlpha
                            star.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                        },
                        completion: { _ in
                            UIView.animate(withDuration: 0.2) {
                                star.transform = .identity
                            }
                        }
                    )
                } else {
                    // For stars becoming inactive, just fade
                    UIView.animate(
                        withDuration: animationDuration,
                        delay: animationDelay * Double(index),
                        options: [.curveEaseInOut],
                        animations: {
                            star.alpha = targetAlpha
                            // Keep current transform
                            star.transform = currentTransforms[index]
                        }
                    )
                }
            }
        }
    }
}

// The StarView class remains the same as before
