//
//  TestScreen.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 05/08/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit

// MARK: - Shape Types
enum ContainerShape: CaseIterable {
    case square
    case rectangleWide
    case rectangleTall
    case roundedSquare
    case roundedRectangleWide
    case roundedRectangleTall
    case circle
    case softRounded
    case heavyRounded
    
    static func random() -> ContainerShape {
        return ContainerShape.allCases.randomElement() ?? .square
    }
    
    var aspectRatio: CGFloat {
        switch self {
        case .square, .roundedSquare, .circle, .softRounded, .heavyRounded:
            return 1.0
        case .rectangleWide, .roundedRectangleWide:
            return 1.4
        case .rectangleTall, .roundedRectangleTall:
            return 0.7
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .square, .rectangleWide, .rectangleTall:
            return 4
        case .roundedSquare, .roundedRectangleWide, .roundedRectangleTall:
            return 16
        case .softRounded:
            return 24
        case .heavyRounded:
            return 32
        case .circle:
            return 0 // Will be calculated as half of min dimension
        }
    }
    
    var borderWidth: CGFloat {
        return CGFloat.random(in: 6...14)
    }
}

// MARK: - Simple Container
class ShapedImageContainerView: UIView {
    private let imageView = UIImageView()
    private let borderView = UIView()
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    var shapeType: ContainerShape = .square {
        didSet {
            updateShape()
        }
    }
    
    var borderWidth: CGFloat = 8 {
        didSet {
            updateShape()
        }
    }
    
    var borderColor: UIColor = .black {
        didSet {
            borderView.backgroundColor = borderColor
        }
    }
    
    var shadowOffset: CGSize = CGSize(width: 25, height: 25) { // Long shadow
        didSet {
            updateShape()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        borderView.backgroundColor = borderColor
        addSubview(borderView)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        borderView.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateShape()
    }
    
    private func updateShape() {
        let maxWidth = bounds.width - abs(shadowOffset.width)
        let maxHeight = bounds.height - abs(shadowOffset.height)
        let aspectRatio = shapeType.aspectRatio
        
        var containerWidth: CGFloat
        var containerHeight: CGFloat
        
        if aspectRatio >= 1.0 {
            containerWidth = maxWidth
            containerHeight = containerWidth / aspectRatio
            if containerHeight > maxHeight {
                containerHeight = maxHeight
                containerWidth = containerHeight * aspectRatio
            }
        } else {
            containerHeight = maxHeight
            containerWidth = containerHeight * aspectRatio
            if containerWidth > maxWidth {
                containerWidth = maxWidth
                containerHeight = containerWidth / aspectRatio
            }
        }
        
        // Position main shape at top-left (shadow extends down-right)
        borderView.frame = CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight)
        
        let imageInset = borderWidth
        imageView.frame = CGRect(
            x: imageInset,
            y: imageInset,
            width: containerWidth - imageInset * 2,
            height: containerHeight - imageInset * 2
        )
        
        let cornerRadius: CGFloat
        if shapeType == .circle {
            cornerRadius = min(containerWidth, containerHeight) / 2
        } else {
            cornerRadius = shapeType.cornerRadius
        }
        
        borderView.layer.cornerRadius = cornerRadius
        imageView.layer.cornerRadius = max(0, cornerRadius - borderWidth)
        
        // Add long shadow using extension
        borderView.addLongShadow(offset: shadowOffset, cornerRadius: cornerRadius)
    }
}

// MARK: - Main View Controller
class TestScreen: UIViewController {
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private var shapedContainers: [ShapedImageContainerView] = []
    
    internal let sampleImages = [
        "image1", "image2", "image3", "image4", "image5", "image6"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        createShapedContainers()
        layoutContainers()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Long Shadow Gallery"
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshShapes)
        )
    }
    
    private func createShapedContainers() {
        shapedContainers.forEach { $0.removeFromSuperview() }
        shapedContainers.removeAll()
        
        for i in 0..<8 {
            let container = ShapedImageContainerView()
            let shape = ContainerShape.random()
            container.shapeType = shape
            container.borderWidth = shape.borderWidth
            
            // Long shadow offset (down and right)
            container.shadowOffset = CGSize(
                width: CGFloat.random(in: 20...35),
                height: CGFloat.random(in: 20...35)
            )
            
            let borderColors: [UIColor] = [
                .black, .systemBlue, .systemPurple, .systemGreen,
                .systemOrange, .systemRed, .systemIndigo, .darkGray
            ]
            container.borderColor = borderColors.randomElement() ?? .black
            
            if i < sampleImages.count {
                container.image = UIImage(named: sampleImages[i])
            } else {
                container.image = createPlaceholderImage(color: UIColor.systemGray2)
            }
            
            containerView.addSubview(container)
            shapedContainers.append(container)
        }
    }
    
    private func layoutContainers() {
        let baseSize: CGFloat = 100
        let spacing: CGFloat = 50 // More space for long shadows
        let margin: CGFloat = 20
        
        let screenWidth = view.bounds.width
        var currentX: CGFloat = margin
        var currentY: CGFloat = margin
        var rowHeight: CGFloat = 0
        
        for container in shapedContainers {
            let aspectRatio = container.shapeType.aspectRatio
            let containerWidth = baseSize * max(aspectRatio, 1.0)
            let containerHeight = baseSize / min(aspectRatio, 1.0)
            
            let totalWidth = containerWidth + container.shadowOffset.width
            let totalHeight = containerHeight + container.shadowOffset.height
            
            if currentX + totalWidth > screenWidth - margin && currentX > margin {
                currentY += rowHeight + spacing
                currentX = margin
                rowHeight = 0
            }
            
            container.frame = CGRect(
                x: currentX,
                y: currentY,
                width: totalWidth,
                height: totalHeight
            )
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(containerTapped(_:)))
            container.addGestureRecognizer(tapGesture)
            container.isUserInteractionEnabled = true
            
            currentX += totalWidth + spacing
            rowHeight = max(rowHeight, totalHeight)
        }
        
        let totalHeight = currentY + rowHeight + margin + 60
        containerView.frame.size.height = totalHeight
    }
    
    @objc private func refreshShapes() {
        createShapedContainers()
        layoutContainers()
        
        shapedContainers.enumerated().forEach { index, container in
            container.alpha = 0
            container.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            
            UIView.animate(
                withDuration: 0.8,
                delay: Double(index) * 0.1,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0.3
            ) {
                container.alpha = 1
                container.transform = .identity
            }
        }
    }
    
    @objc private func containerTapped(_ gesture: UITapGestureRecognizer) {
        guard let container = gesture.view as? ShapedImageContainerView else { return }
        
        let newShape = ContainerShape.random()
        container.shapeType = newShape
        container.borderWidth = newShape.borderWidth
        
        // New long shadow on tap
        container.shadowOffset = CGSize(
            width: CGFloat.random(in: 20...35),
            height: CGFloat.random(in: 20...35)
        )
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.2) {
            container.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                container.transform = .identity
            }
        }
    }
    
    private func createPlaceholderImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
