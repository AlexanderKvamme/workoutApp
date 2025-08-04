import UIKit

class FormFittingActionButton: UIButton {
    private let iconImageView = UIImageView()
    private let label = UILabel()
    private let stackView = UIStackView()
    
    var buttonColor: UIColor = .systemBlue {
        didSet {
            updateAppearance()
        }
    }
    
    var buttonTitle: String = "" {
        didSet {
            label.text = buttonTitle
        }
    }
    
    var iconName: String? {
        didSet {
            updateIcon()
        }
    }
    
    var buttonFont: UIFont = UIFont.boldSystemFont(ofSize: 20) {
        didSet {
            label.font = buttonFont
        }
    }
    
    var buttonAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    convenience init(title: String, icon: String? = nil, color: UIColor = .systemBlue, font: UIFont = UIFont.boldSystemFont(ofSize: 20), action: (() -> Void)? = nil) {
        self.init(frame: .zero)
        self.buttonTitle = title
        self.iconName = icon
        self.buttonColor = color
        self.buttonFont = font
        self.buttonAction = action
        
        label.text = title
        label.font = font
        updateIcon()
        updateAppearance()
    }
    
    private func setupUI() {
        // Configure stack view
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.isUserInteractionEnabled = false
        
        // Configure icon image view
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.isHidden = true
        
        // Configure title label - use the buttonFont property
        label.font = buttonFont
        label.textColor = .white
        label.textAlignment = .center
        
        // Add subviews
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(label)
        
        addSubview(stackView)
        
        // Setup constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16)
        ])
        
        // Setup button action
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        // Initial appearance
        updateAppearance()
    }
    
    private func updateIcon() {
        if let iconName = iconName {
            let config = UIImage.SymbolConfiguration(weight: .bold)
            iconImageView.image = UIImage(systemName: iconName, withConfiguration: config)
            iconImageView.isHidden = false
        } else {
            iconImageView.image = nil
            iconImageView.isHidden = true
        }
    }
    
    private func updateAppearance() {
        backgroundColor = buttonColor
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    @objc private func buttonTapped() {
        buttonAction?()
    }
}
