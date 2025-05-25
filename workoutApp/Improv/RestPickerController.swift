import UIKit
import AKKIT

class RestDurationPickerController: UIViewController {
    
    // MARK: - Properties
    private let titleLabel = UILabel()
    private let stepperFrame = CGRect(x: 0, y: 0, width: 222, height: 64)
    private let durationOptions = ["30 s", "1 m", "2 m", "3 m", "4 m", "5 m"]
    private let superStepper: SuperStepper
    private let confirmButton = UIButton()
    private let closeButton = UIButton.make(.x)
    
    // Completion handler to execute when a rest duration is selected
    private let completionHandler: (String) -> Void
    
    // Flag to determine if this controller is in a navigation stack
    private let isInNavigationStack: Bool
    
    // MARK: - Initializers
    init(currentPick: String, completionHandler: @escaping (String) -> Void, isInNavigationStack: Bool = false) {
        self.completionHandler = completionHandler
        self.isInNavigationStack = isInNavigationStack
        self.superStepper = SuperStepper(frame: stepperFrame, options: durationOptions, initialSelection: currentPick)
        
        superStepper.activeColor = .black

        super.init(nibName: nil, bundle: nil)
        
        // Set modal presentation style only if not in navigation stack
        if !isInNavigationStack {
            modalPresentationStyle = .pageSheet
            if #available(iOS 15.0, *) {
                if let sheet = sheetPresentationController {
                    sheet.detents = [.custom { _ in return 250 }]  // Smaller fixed height
                    sheet.prefersGrabberVisible = true
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        
        setupUI()
        setupConstraints()
        
        // If in navigation stack, set up navigation bar
        if isInNavigationStack {
            title = "Rest Duration"
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(dismissPicker)
            )
            navigationItem.leftBarButtonItem?.tintColor = .black
        }
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Configure title label
        titleLabel.text = "Rest Duration"
        titleLabel.font = AKFont.round(.black, 28)  // Slightly smaller font
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        
        // Configure stepper
        superStepper.backgroundColor = .white
        superStepper.layer.cornerRadius = 12
        
        // Configure confirm button
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.backgroundColor = .black
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = AKFont.round(.bold, 18)
        confirmButton.layer.cornerRadius = 12
        confirmButton.addTarget(self, action: #selector(confirmSelection), for: .touchUpInside)
        
        // Configure close button - only show if modal
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(dismissPicker), for: .touchUpInside)
        closeButton.isHidden = isInNavigationStack
        
        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(superStepper)
        view.addSubview(confirmButton)
        view.addSubview(closeButton)
    }
    
    private func setupConstraints() {
        // Adjust title label position based on presentation style
        titleLabel.snp.makeConstraints { make in
            if isInNavigationStack {
                make.top.equalTo(view.safeAreaLayoutGuide).offset(24)  // Reduced top offset
            } else {
                make.top.equalTo(view.safeAreaLayoutGuide).offset(24)  // Reduced top offset
            }
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
        
        // Only position close button if not in navigation stack
        if !isInNavigationStack {
            closeButton.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(12)  // Reduced top offset
                make.right.equalTo(view.safeAreaLayoutGuide).offset(-16)
                make.size.equalTo(28)  // Slightly smaller button
            }
        }
        
        superStepper.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(superStepper.frame.size)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)  // Reduced spacing
        }
        
        confirmButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(superStepper.snp.bottom).offset(24)  // Reduced spacing
            make.width.equalTo(180)  // Slightly narrower button
            make.height.equalTo(44)  // Slightly shorter button
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)  // Add bottom constraint
        }
    }
    
    // MARK: - Action Methods
    @objc private func confirmSelection() {
        // Get the selected duration from the stepper
        guard let durationText = superStepper.getCurrentValue() else {
            print("Error: Could not get duration from stepper")
            return
        }
        
        // Execute the completion handler with the selected duration
        completionHandler(durationText)
        
        // Navigate back or dismiss based on presentation style
        navigateBack()
    }
    
    @objc private func dismissPicker() {
        navigateBack()
    }
    
    private func navigateBack() {
        if isInNavigationStack {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    // Override size for more compact presentation
    override var preferredContentSize: CGSize {
        get {
            return CGSize(width: UIScreen.main.bounds.width, height: 250)
        }
        set { super.preferredContentSize = newValue }
    }
}
