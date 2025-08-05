//
//  CollageTestScreen.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 05/08/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit

class CollageTestScreen: UIViewController {
    
    private let collageView = CollageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collageView.startAnimation()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Collage Animation"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(resetAnimation)
        )
    }
    
    private func setupCollageView() {
        // Configure the collage view
        collageView.images = ["md-image-1", "md-image-2", "md-image-3", "md-image-4"]
        collageView.centerShapeSize = 180
        collageView.baseDistance = 120
        collageView.borderColor = .black
        
        // Add to view with constraints
        collageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collageView)
        
        NSLayoutConstraint.activate([
            collageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            collageView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        // Setup the collage
        collageView.setupCollage()
    }
    
    @objc private func resetAnimation() {
        collageView.resetAnimation()
    }
}
