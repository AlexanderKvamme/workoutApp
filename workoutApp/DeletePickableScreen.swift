import UIKit
import SnapKit
import CoreData

class DeletePickableScreen: UIViewController {
    
    // MARK: - Properties
    
    private let pickable: PickableEntity
    private let completion: (() -> Void)?

    private lazy var onDelete: (PickableEntity) -> Void = { [weak self] (entity: PickableEntity) in
        DatabaseFacade.delete(entity as! NSManagedObject)
        self?.navigationController?.popViewController(animated: true)
    }
    private let onCancel: () -> Void
    
    init(pickable: PickableEntity, completion: (() -> Void)? = nil) {
        self.pickable = pickable
        let onCancel: () -> Void = {
            print("cancel")
        }
        self.onCancel = onCancel
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private lazy var warningIcon: UIImageView = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular)
        let image = UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: configuration)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .systemRed
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Delete \(pickable.name ?? "")?"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "This action cannot be undone. Are you sure you want to delete this item?"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        return stack
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor.systemGray6
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    
    init(pickable: PickableEntity, completion: (() -> Void)? = nil, onDelete: @escaping (PickableEntity) -> Void, onCancel: @escaping () -> Void) {
        self.pickable = pickable
        self.onCancel = onCancel
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        view.addSubview(containerView)
        containerView.addSubview(warningIcon)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(buttonStack)
        
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(deleteButton)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(320)
            make.height.lessThanOrEqualTo(400)
        }
        
        warningIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(warningIcon.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(24)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(24)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-24)
            make.height.equalTo(50)
        }
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        dismiss(animated: true) {
            self.onCancel()
            self.completion?()
        }
    }
    
    @objc private func deleteTapped() {
        dismiss(animated: true) {
            self.onDelete(self.pickable)
            self.completion?()
        }
    }
}

// MARK: - Usage Example

// Example of how to use this screen:
/*
// Assuming you have a Pickable object
let myPickable = YourPickableObject(name: "Workout", id: "123")

// Create and present the delete confirmation screen
let deleteScreen = DeletePickableScreen(
    pickable: myPickable,
    onDelete: { pickable in
        // Handle deletion here
        print("Deleting \(pickable.name)")
        // Delete from database, etc.
    },
    onCancel: {
        // Handle cancellation (optional)
        print("Deletion cancelled")
    }
)

// Present the screen
present(deleteScreen, animated: true)
*/
