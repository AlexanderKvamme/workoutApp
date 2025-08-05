////
////  TestScreen.swift
////  workoutApp
////
////  Created by Alexander Kvamme on 05/08/2025.
////  Copyright © 2025 Alexander Kvamme. All rights reserved.
////
//
//import UIKit
//
//// MARK: - Shape Types (Add this enum)
//enum ContainerShape: CaseIterable {
//    case square
//    case rectangleWide
//    case rectangleTall
//    case roundedSquare
//    case roundedRectangleWide
//    case roundedRectangleTall
//    case circle
//    case softRounded
//    case heavyRounded
//    
//    static func random() -> ContainerShape {
//        return ContainerShape.allCases.randomElement() ?? .square
//    }
//    
//    var aspectRatio: CGFloat {
//        switch self {
//        case .square, .roundedSquare, .circle, .softRounded, .heavyRounded:
//            return 1.0
//        case .rectangleWide, .roundedRectangleWide:
//            return 1.4
//        case .rectangleTall, .roundedRectangleTall:
//            return 0.7
//        }
//    }
//    
//    var cornerRadius: CGFloat {
//        switch self {
//        case .square, .rectangleWide, .rectangleTall:
//            return 4
//        case .roundedSquare, .roundedRectangleWide, .roundedRectangleTall:
//            return 16
//        case .softRounded:
//            return 24
//        case .heavyRounded:
//            return 32
//        case .circle:
//            return 0 // Will be calculated as half of min dimension
//        }
//    }
//    
//    var borderWidth: CGFloat {
//        return CGFloat.random(in: 6...14)
//    }
//}
//
//// MARK: - Shaped Image Container View (Add this class)
//class ShapedImageContainerView: UIView {
//    private let imageView = UIImageView()
//    private let borderView = UIView()
//    private let shadowView = UIView() // Solid black shadow
//    
//    var image: UIImage? {
//        didSet {
//            imageView.image = image
//        }
//    }
//    
//    var shapeType: ContainerShape = .square {
//        didSet {
//            updateShape()
//        }
//    }
//    
//    var borderWidth: CGFloat = 8 {
//        didSet {
//            updateShape()
//        }
//    }
//    
//    var borderColor: UIColor = .black {
//        didSet {
//            borderView.backgroundColor = borderColor
//        }
//    }
//    
//    // Shadow properties
//    var shadowOffset: CGSize = CGSize(width: 0, height: 20) {
//        didSet {
//            updateShape()
//        }
//    }
//    
//    var shadowOpacity: CGFloat = 1.0 {
//        didSet {
//            shadowView.alpha = shadowOpacity
//        }
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//    }
//    
//    private func setupView() {
//        // Setup solid black shadow view (add first so it's behind)
//        shadowView.backgroundColor = UIColor.black
//        shadowView.alpha = shadowOpacity
//        addSubview(shadowView)
//        
//        // Setup border view
//        borderView.backgroundColor = borderColor
//        addSubview(borderView)
//        
//        // Setup image view
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        borderView.addSubview(imageView)
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        updateShape()
//    }
//    
//    private func updateShape() {
//        // Calculate dimensions based on aspect ratio
//        let maxWidth = bounds.width
//        let maxHeight = bounds.height - abs(shadowOffset.height) // Account for shadow space
//        let aspectRatio = shapeType.aspectRatio
//        
//        var containerWidth: CGFloat
//        var containerHeight: CGFloat
//        
//        if aspectRatio >= 1.0 {
//            containerWidth = maxWidth
//            containerHeight = containerWidth / aspectRatio
//            if containerHeight > maxHeight {
//                containerHeight = maxHeight
//                containerWidth = containerHeight * aspectRatio
//            }
//        } else {
//            containerHeight = maxHeight
//            containerWidth = containerHeight * aspectRatio
//            if containerWidth > maxWidth {
//                containerWidth = maxWidth
//                containerHeight = containerWidth / aspectRatio
//            }
//        }
//        
//        // Center the container (accounting for shadow)
//        let containerX = (bounds.width - containerWidth) / 2
//        let containerY = (bounds.height - containerHeight - abs(shadowOffset.height)) / 2
//        
//        // Position shadow view first (behind the main view)
//        shadowView.frame = CGRect(
//            x: containerX + shadowOffset.width,
//            y: containerY + shadowOffset.height,
//            width: containerWidth,
//            height: containerHeight
//        )
//        
//        // Position main border view
//        borderView.frame = CGRect(
//            x: containerX,
//            y: containerY,
//            width: containerWidth,
//            height: containerHeight
//        )
//        
//        // Position image view inside border
//        let imageInset = borderWidth
//        imageView.frame = CGRect(
//            x: imageInset,
//            y: imageInset,
//            width: containerWidth - imageInset * 2,
//            height: containerHeight - imageInset * 2
//        )
//        
//        // Apply corner radius
//        let cornerRadius: CGFloat
//        if shapeType == .circle {
//            cornerRadius = min(containerWidth, containerHeight) / 2
//        } else {
//            cornerRadius = shapeType.cornerRadius
//        }
//        
//        // Apply same corner radius to both shadow and main views
//        shadowView.layer.cornerRadius = cornerRadius
//        borderView.layer.cornerRadius = cornerRadius
//        imageView.layer.cornerRadius = max(0, cornerRadius - borderWidth)
//    }
//}
//
//// MARK: - Main View Controller (Your existing class with fixes)
//class TestScreen: UIViewController {
//    
//    private let scrollView = UIScrollView()
//    private let containerView = UIView()
//    private var shapedContainers: [ShapedImageContainerView] = []
//    
//    // Sample images - replace with your actual images (made internal instead of private)
//    internal let sampleImages = [
//        "image1", "image2", "image3", "image4", "image5", "image6"
//    ]
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        createShapedContainers()
//        layoutContainers()
//    }
//    
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//        title = "Shaped Image Gallery"
//        
//        // Setup scroll view
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(scrollView)
//        scrollView.addSubview(containerView)
//        
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
//        ])
//        
//        // Add refresh button
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            barButtonSystemItem: .refresh,
//            target: self,
//            action: #selector(refreshShapes)
//        )
//    }
//    
//    private func createShapedContainers() {
//        // Clear existing containers
//        shapedContainers.forEach { $0.removeFromSuperview() }
//        shapedContainers.removeAll()
//        
//        // Create new containers with random shapes and solid shadows
//        for i in 0..<8 {
//            let container = ShapedImageContainerView()
//            let shape = ContainerShape.random()
//            container.shapeType = shape
//            container.borderWidth = shape.borderWidth
//            
//            // Set shadow offset (270 degrees = straight down)
//            container.shadowOffset = CGSize(width: 0, height: CGFloat.random(in: 15...30))
//            
//            // Random border colors
//            let borderColors: [UIColor] = [
//                .black, .systemBlue, .systemPurple, .systemGreen,
//                .systemOrange, .systemRed, .systemIndigo, .darkGray
//            ]
//            container.borderColor = borderColors.randomElement() ?? .black
//            
//            // Set image
//            if i < sampleImages.count {
//                container.image = UIImage(named: sampleImages[i])
//            } else {
//                container.image = createPlaceholderImage(color: UIColor.systemGray2)
//            }
//            
//            containerView.addSubview(container)
//            shapedContainers.append(container)
//        }
//    }
//    
//    private func layoutContainers() {
//        let baseSize: CGFloat = 100
//        let spacing: CGFloat = 40 // More spacing to accommodate shadows
//        let margin: CGFloat = 20
//        
//        let screenWidth = view.bounds.width
//        var currentX: CGFloat = margin
//        var currentY: CGFloat = margin
//        var rowHeight: CGFloat = 0
//        
//        for container in shapedContainers {
//            let aspectRatio = container.shapeType.aspectRatio
//            let containerWidth = baseSize * max(aspectRatio, 1.0)
//            let containerHeight = baseSize / min(aspectRatio, 1.0)
//            
//            // Add shadow height to total height needed
//            let totalHeight = containerHeight + abs(container.shadowOffset.height)
//            
//            // Check if container fits in current row
//            if currentX + containerWidth > screenWidth - margin && currentX > margin {
//                currentY += rowHeight + spacing
//                currentX = margin
//                rowHeight = 0
//            }
//            
//            container.frame = CGRect(
//                x: currentX,
//                y: currentY,
//                width: containerWidth,
//                height: totalHeight
//            )
//            
//            // Add tap gesture
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(containerTapped(_:)))
//            container.addGestureRecognizer(tapGesture)
//            container.isUserInteractionEnabled = true
//            
//            // Update position for next container
//            currentX += containerWidth + spacing
//            rowHeight = max(rowHeight, totalHeight)
//        }
//        
//        // Update container view height
//        let totalHeight = currentY + rowHeight + margin + 60
//        containerView.frame.size.height = totalHeight
//    }
//    
//    @objc private func refreshShapes() {
//        createShapedContainers()
//        layoutContainers()
//        
//        // Animate the refresh
//        shapedContainers.enumerated().forEach { index, container in
//            container.alpha = 0
//            container.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
//            
//            UIView.animate(
//                withDuration: 0.8,
//                delay: Double(index) * 0.1,
//                usingSpringWithDamping: 0.6,
//                initialSpringVelocity: 0.3
//            ) {
//                container.alpha = 1
//                container.transform = .identity
//            }
//        }
//    }
//    
//    @objc private func containerTapped(_ gesture: UITapGestureRecognizer) {
//        guard let container = gesture.view as? ShapedImageContainerView else { return }
//        
//        // Change to random shape on tap
//        let newShape = ContainerShape.random()
//        container.shapeType = newShape
//        container.borderWidth = newShape.borderWidth
//        
//        // Add bounce animation
//        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.2) {
//            container.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
//        } completion: { _ in
//            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
//                container.transform = .identity
//            }
//        }
//    }
//    
//    private func createPlaceholderImage(color: UIColor) -> UIImage {
//        let size = CGSize(width: 200, height: 200)
//        let renderer = UIGraphicsImageRenderer(size: size)
//        return renderer.image { context in
//            color.setFill()
//            context.fill(CGRect(origin: .zero, size: size))
//        }
//    }
//}
