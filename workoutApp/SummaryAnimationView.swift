//
//  SummaryAnimationView.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 19/02/2023.
//  Copyright © 2023 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT


final class SummaryAnimationView: UIView {
    
    // MARK: - Properties
    
    private var circleView = DottedCircleView()
    private var circleShapeLayer: CAShapeLayer!
    private var userProfileView = UserProfileView()
    
    // MARK: - Initializers
    
    init() {
        let frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth)
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func start() {
        userProfileView.startPulseAnimation()
    }
    
    private func setup() {
        backgroundColor = .green
        
        // TEST ROTATING VEIW
        let elements: [RotatingElementType] = [.fire, .eye, .clock, .category, .priceLabel]
        for (idx, element) in elements.enumerated() {
            let rotatingView = RotatingElement(element: element)
            rotatingView.frame.origin = CGPoint(x: idx*80, y: idx*80)
            addSubview(rotatingView)
        }
        
        addSubview(circleView)
        circleView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(80)
        }
        
        addSubview(userProfileView)
        userProfileView.snp.makeConstraints { make in
            make.center.equalTo(circleView)
            make.size.equalTo(60)
        }
    }
    
}

final class DottedCircleView: UIView {
    
    init() {
        super.init(frame: .zero)
        addCircularThing()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addCircularThing()
    }
    
    private func addCircularThing() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.akCard.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.lineCap = .round
        shapeLayer.lineDashPattern = [4, 8]
        
        //
        let rect = bounds.insetBy(dx: shapeLayer.lineWidth / 2, dy: shapeLayer.lineWidth / 2)
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        shapeLayer.path = path.cgPath
        layer.addSublayer(shapeLayer)
    }
    
}

final class UserProfileView: UIView {
    
    // MARK: - Properties
    
    private let imageView = UIImageView()
    private let animatedExpander = UIView()
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerCurve = .continuous
        layer.cornerRadius = frame.width/2
        animatedExpander.layer.cornerCurve = .continuous
        animatedExpander.layer.cornerRadius = animatedExpander.frame.width/2
    }
    
    // MARK: - Methods
    
    private func setup() {
        addSubview(animatedExpander)
        backgroundColor = .akDark
        self.animatedExpander.alpha = 0.4
        animatedExpander.backgroundColor = .akDark
        let image = UIImage(named: "User")!
        imageView.image = image
        
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalToSuperview().inset(16)
        }
        
        animatedExpander.snp.makeConstraints { make in
            make.size.equalTo(self)
            make.center.equalTo(self)
        }
        
    }
    
    func startPulseAnimation() {
        setNeedsLayout()
        layoutIfNeeded()
        UIView.animate(withDuration: 3.0,
                       delay: 0.0,
                       options: [.curveLinear, .repeat],
                       animations: { () -> Void in
            self.animatedExpander.transform = self.animatedExpander.transform.scaledBy(x: 1.6, y: 1.6)
            self.animatedExpander.alpha = 0
        }, completion: { (finished: Bool) -> Void in
            self.animatedExpander.alpha = 0.4
        })
    }

}

enum RotatingElementType: String {
    case fire = "Fire"
    case threeDots = "3 Dot Horizontal"
    case star = "Star"
    case category = "Category"
    case home = "Home"
    case emoticon = "Emoticon"
    case notification = "Notification"
    case ticket = "Ticket"
    case priceLabel = "Price Label"
    case box = "Box"
    case lock = "Lock"
    case scanning = "Scanning"
    case globe = "Globe"
    case location = "Location"
    case struck = "Struck"
    case eye = "Eye"
    case clock = "Clock"
    case clock2 = "Clock 2"
    case love = "Love"
    case user = "User"
    case checklist = "Checklist"
}

final class RotatingElement: UIView {
    
    // MARK: - Properties
    
    private var imageview = UIImageView()
    
    // MARK: - Initializers
    
    init(element: RotatingElementType) {
        super.init(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        imageview.image = UIImage(named: element.rawValue)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    // MARK: - Methods
    
    private func setup() {
        layer.cornerCurve = .continuous
        layer.cornerRadius = 8
        backgroundColor = .akDark
        
        addSubview(imageview)
        imageview.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }
}
