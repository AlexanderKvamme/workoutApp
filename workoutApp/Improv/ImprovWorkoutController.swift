//import UIKit
//import AKKIT
//
//
//// MARK: - ImprovWorkoutController
//class ImprovWorkoutController: UIViewController {
//    private let muscleGroup: Muscle
//    
//    init(muscleGroup: Muscle) {
//        self.muscleGroup = muscleGroup
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .akLight
//        
//        // Set up the view with the selected muscle group
//        setupView()
//        styleBackButton()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
//    
//    private func setupView() {
//        // Title label
//        let titleLabel = UILabel()
//        titleLabel.text = muscleGroup.name
//        titleLabel.font = AKFont.round(.bold, 24)
//        titleLabel.textColor = .white
//        titleLabel.textAlignment = .center
//        
//        view.addSubview(titleLabel)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
//        ])
//        
//        // Add more UI components as needed for your workout view
//    }
//}
