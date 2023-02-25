//
//  SummaryAnimationView.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 19/02/2023.
//  Copyright © 2023 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT
import SnapKit


let akGray = UIColor(hexString: "EDEDED")

final class SummaryAnimationView: UIView {
    
    // MARK: - Properties
    
    private var circleView = DottedCircleView()
    private var circleShapeLayer: CAShapeLayer!
    private var userProfileView = UserProfileView()
    private var circleInset: CGFloat = 50
    
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
        addRotatingElements()
    }
    
    private func addRotatingElements() {
        let elements: [RotatingElementType] = [.fire, .eye, .clock, .category, .priceLabel]
        for (idx, element) in elements.enumerated() {
            let rotatingView = RotatingElement(element: element)
            addSubview(rotatingView)
            startOrbiting(rotatingView, no: idx, of: elements.count)
        }
    }
    
    private func setup() {
        addSubview(circleView)
        circleView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(circleInset)
        }
        
        addSubview(userProfileView)
        userProfileView.snp.makeConstraints { make in
            make.center.equalTo(circleView)
            make.size.equalTo(60)
        }
        
    }
    
    private func startOrbiting(_ element: UIView, no: Int, of: Int) {
        let circlePath = circleView.getPath().translated(by: CGPoint(x: circleInset, y: circleInset))
        let animation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        animation.path = circlePath
        animation.duration = 200
        animation.repeatCount = .infinity
        animation.timeOffset = animation.duration*Double(no)/Double(of)
        addSubview(element)
        element.layer.add(animation, forKey: nil)
    }
    
}

final class DottedCircleView: UIView {
    
    var path: CGPath!
    
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
        shapeLayer.strokeColor = akGray.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.lineCap = .round
        shapeLayer.lineDashPattern = [4, 8]
        
        let rect = bounds.insetBy(dx: shapeLayer.lineWidth / 2, dy: shapeLayer.lineWidth / 2)
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        shapeLayer.path = path.cgPath
        self.path = path.cgPath
        layer.addSublayer(shapeLayer)
    }
    
    func getPath() -> CGPath {
        return path
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
        self.animatedExpander.alpha = 0.2
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
            self.animatedExpander.alpha = 0.2
        })
        
        // Self pulse
        UIView.animate(withDuration: 3, delay: 0, options: [.autoreverse, .curveEaseIn, .repeat], animations: {
            self.transform = self.transform.scaledBy(x: 1.1, y: 1.1)
        }, completion: nil)
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
        super.init(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageview.image = UIImage(named: element.rawValue)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

extension CGPath {
    func translated(by point: CGPoint) -> CGPath? {
        let bezeirPath = UIBezierPath()
        bezeirPath.cgPath = self
        bezeirPath.apply(CGAffineTransform(translationX: point.x, y: point.y))
        return bezeirPath.cgPath
    }
}

final class SummarySectionView: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    var labelTitle = UILabel()
    var items = ["100 sets", "56m total", "3m pause", "100 reps", "4 workouts this week", "4 workouts this year"]
    var collectionView: UICollectionView!
    let layout = CenterAlignedCollectionViewFlowLayout()
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func setup() {
        labelTitle.font = UIFont.custom(style: .bold, ofSize: .big)
        labelTitle.textColor = .akDark
        view.addSubview(labelTitle)
        labelTitle.text = "SUMMARY"
        labelTitle.textAlignment = .center
        labelTitle.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        // Layout
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        // Collectionview
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SummaryCell.self, forCellWithReuseIdentifier: SummaryCell.cellIdentifier)
        collectionView.backgroundColor = .clear
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(labelTitle.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview().inset(24)
        }
    }
    
    // MARK: - Delegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SummaryCell.cellIdentifier, for: indexPath) as! SummaryCell
        
        cell.update(with: item)
        return cell
    }
    
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}


final class SummaryCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let cellIdentifier = "SummaryCell"
    
    private var label = UILabel()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func setup() {
        contentView.addSubview(label)
        label.font = UIFont.custom(style: .bold, ofSize: .smallPlus)
        label.textColor = .akDark
        
        contentView.backgroundColor = akGray
        contentView.layer.cornerRadius = 8
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        snp.makeConstraints { make in
            make.size.equalTo(contentView)
        }
        
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8).priority(.high)
        }
        
        contentView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    
    func update(with item: String) {
        label.text = item
    }
}


class CenterAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        // Copy each item to prevent "UICollectionViewFlowLayout has cached frame mismatch" warning
        guard let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return nil }
        
        // Constants
        let leftPadding: CGFloat = 8
        let interItemSpacing = minimumInteritemSpacing
        
        // Tracking values
        var leftMargin: CGFloat = leftPadding // Modified to determine origin.x for each item
        var maxY: CGFloat = -1.0 // Modified to determine origin.y for each item
        var rowSizes: [[CGFloat]] = [] // Tracks the starting and ending x-values for the first and last item in the row
        var currentRow: Int = 0 // Tracks the current row
        attributes.forEach { layoutAttribute in
            
            // Each layoutAttribute represents its own item
            if layoutAttribute.frame.origin.y >= maxY {
                
                // This layoutAttribute represents the left-most item in the row
                leftMargin = leftPadding
                
                // Register its origin.x in rowSizes for use later
                if rowSizes.count == 0 {
                    // Add to first row
                    rowSizes = [[leftMargin, 0]]
                } else {
                    // Append a new row
                    rowSizes.append([leftMargin, 0])
                    currentRow += 1
                }
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + interItemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
            
            // Add right-most x value for last item in the row
            rowSizes[currentRow][1] = leftMargin - interItemSpacing
        }
        
        // At this point, all cells are left aligned
        // Reset tracking values and add extra left padding to center align entire row
        leftMargin = leftPadding
        maxY = -1.0
        currentRow = 0
        attributes.forEach { layoutAttribute in
            
            // Each layoutAttribute is its own item
            if layoutAttribute.frame.origin.y >= maxY {
                
                // This layoutAttribute represents the left-most item in the row
                leftMargin = leftPadding
                
                // Need to bump it up by an appended margin
                let rowWidth = rowSizes[currentRow][1] - rowSizes[currentRow][0] // last.x - first.x
                let appendedMargin = (collectionView!.frame.width - leftPadding  - rowWidth - leftPadding) / 2
                leftMargin += appendedMargin
                
                currentRow += 1
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + interItemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        
        return attributes
    }
}


final class BigButton: UIView {
    
    // MARK: - Properties
    
    let label = UILabel()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth-48, height: 48))
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func setup() {
        backgroundColor = .black
        label.font = UIFont.custom(style: .bold, ofSize: .mediumPlus)
        label.textAlignment = .center
        label.text = "DISMISS"
        label.textColor = .white
        layer.cornerCurve = .continuous
        layer.cornerRadius = 16
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
