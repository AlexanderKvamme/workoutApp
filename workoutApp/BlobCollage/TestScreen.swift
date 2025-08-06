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
        return [
        ContainerShape.roundedSquare,
        ContainerShape.roundedRectangleWide,
        ContainerShape.roundedRectangleTall,
        ContainerShape.circle,
//        ContainerShape.softRounded,
//        ContainerShape.heavyRounded
        ].randomElement() ?? .square
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
            return 10
        case .roundedSquare, .roundedRectangleWide, .roundedRectangleTall:
            return 20
        case .softRounded:
            return 30
        case .heavyRounded:
            return 40
        case .circle:
            return 0 // Will be calculated as half of min dimension
        }
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
    
    var borderWidth: CGFloat = 10 {
        didSet {
            updateShape()
        }
    }
    
    var borderColor: UIColor = .black {
        didSet {
            borderView.backgroundColor = borderColor
        }
    }
    
    var shadowOffset: CGSize = CGSize(width: -10, height: 10) { // Long shadow
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
        
        // Calculate inner corner radius based on the imageView's actual dimensions
        if shapeType == .circle {
            imageView.layer.cornerRadius = min(imageView.frame.width, imageView.frame.height) / 2
        } else {
            // For rounded rectangles, use the same proportion as the outer shape
            let outerSize = min(containerWidth, containerHeight)
            let innerSize = min(imageView.frame.width, imageView.frame.height)
            let radiusRatio = cornerRadius / outerSize
            imageView.layer.cornerRadius = radiusRatio * innerSize
        }
        
        // Add long shadow using extension
        borderView.addLongShadow(offset: shadowOffset, cornerRadius: cornerRadius)
    }
    
}

// MARK: - Main View Controller
//class TestScreen: UIViewController {}
