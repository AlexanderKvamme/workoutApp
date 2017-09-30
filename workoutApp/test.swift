//
//  PreferencesViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 19/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    // MARK: - Properties
    
    private lazy var progressPlaceholderImageView: UIImageView = {
        let image = UIImage(named: "progressPlaceholder")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .light
//        addSubviewsAndConstraints()
        
        addProfileTest()
    }
    
    // MARK: Methods
    
    private func addProfileTest() {
//        let pc = ProfileController()
//        addChildViewController(pc)
//        view.addSubview(pc.view)
        
        let sc = SuggestionController()
        addChildViewController(sc)
        view.addSubview(sc.view)
    }
    
    private func addSubviewsAndConstraints() {
        
        // progressPlaceholder
        view.addSubview(progressPlaceholderImageView)
        let progressSpacing: CGFloat = 20
        NSLayoutConstraint.activate([
            progressPlaceholderImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: progressSpacing),
            progressPlaceholderImageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -progressSpacing),
            progressPlaceholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
    }
}

