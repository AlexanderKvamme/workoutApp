//
//  AKSuperStepper.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 08/01/2023.
//  Copyright © 2023 Alexander Kvamme. All rights reserved.
//

import Foundation
import AKKIT
import UIKit
// Heavily inspired by: https://dribbble.com/shots/5586623-Stepper-IX

final class SuperStepper: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    // MARK: - Properties

    let data: [String]
    var dataViews = [StepperDataView]()
    var dataViewStack = UIStackView()
    let hScroll = UIScrollView()
    var activeColor: UIColor?
    var inactiveColor: UIColor?
    
    // Shadow view
    private let shadowView = ShadowView()
    private let contentButton = UIButton()
    
    var delegate: AKStepperDelegate?

    // MARK: - Initializers

    init(frame: CGRect, options: [String], activeColor: UIColor? = nil, inactiveColor: UIColor? = nil) {
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.data = options
        
        super.init(frame: frame)

        setup()
        addSubviewsAndConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func setup() {
        // Configure shadow view
        shadowView.frame = bounds
        shadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Configure content button
        contentButton.frame = bounds
        contentButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentButton.layer.cornerRadius = 16
        contentButton.clipsToBounds = true
        
        let dataViewSize = CGRect(x: 0, y: 0, width: frame.width/3, height: frame.height)
        dataViews = data.map({ return StepperDataView(frame: dataViewSize, value: $0) })
        hScroll.contentInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)

        dataViews.forEach({ dataViewStack.addArrangedSubview($0) })
        dataViewStack.axis = .horizontal
        dataViewStack.distribution = .fillEqually
        let totalSpacing = CGFloat(dataViews.count - 1) * dataViewStack.spacing
        let contentSize = CGSize(width: dataViewSize.width*CGFloat(dataViews.count) + totalSpacing, height: frame.height)
        dataViewStack.frame.size = contentSize
        hScroll.frame = contentButton.bounds
        hScroll.contentMode = .center
        hScroll.contentSize = contentSize
        hScroll.bounces = true
        hScroll.alwaysBounceHorizontal = true
        hScroll.showsHorizontalScrollIndicator = false
        hScroll.delegate = self
        
        updateColors(forIdx: 0)

        let tr = UILongPressGestureRecognizer(target: self, action: #selector(tapped))
        tr.minimumPressDuration = 0
        tr.cancelsTouchesInView = false
        tr.delaysTouchesBegan = false
        tr.delegate = self
        dataViewStack.addGestureRecognizer(tr)

        updateViewsStyle(hScroll)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    var tapOrigin: CGPoint?

    @objc func tapped(_ sender: UIGestureRecognizer) {
        if sender.state == .began {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            tapOrigin = sender.location(in: self)

            UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 5, options: []) {
                self.contentButton.transform = CGAffineTransform.init(scaleX: 0.98, y: 0.98)
            }
        }

        if sender.state == .ended {
            // On short tap, scroll to target
            let origin = Int(tapOrigin!.x.rounded())
            let new = Int(sender.location(in: self).x.rounded())
            if abs(origin - new) < 3 {
                let loc = sender.location(in: hScroll)
                if let width = dataViews.first?.frame.width {
                    let idx = Int(loc.x/width)
                    handleWillGoToIndex(idx)
                    delegate?.didSelectValue(self.data[idx])
                    let newPoint = CGPoint(x: CGFloat(idx)*width-width, y: 0)
                    hScroll.setContentOffset(newPoint, animated: true)
                }
            }

            tapOrigin = nil

            // Shake and restore identity transform
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 5, options: []) {
                self.contentButton.transform = CGAffineTransform.identity
            }
        }
    }

    func addSubviewsAndConstraints() {
        // Add shadow view first (underneath)
        addSubview(shadowView)
        
        // Add content button on top of shadow
        addSubview(contentButton)
        
        // Add scroll view to content button
        contentButton.addSubview(hScroll)
        hScroll.addSubview(dataViewStack)
        
        // Position shadow view to be slightly offset from the content button
        shadowView.snp.makeConstraints { make in
            make.top.equalTo(contentButton.snp.top).offset(10)
            make.left.equalTo(contentButton.snp.left)
            make.right.equalTo(contentButton.snp.right)
            make.bottom.equalTo(contentButton.snp.bottom).offset(10)
        }
    }

    // MARK: - ScrollViewDelegate
    
    // Snap to points after letting go of scroll touch
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let dataViewWidth = dataViews.first?.frame.width else { return }
        var x = targetContentOffset.pointee.x
        if x == 0 {
            x = -1
        }
        let mod = Int((x+dataViewWidth/2)/dataViewWidth)
        handleWillGoToIndex(mod)
        
        var newX = CGFloat(mod)*dataViewWidth
        if -dataViewWidth/2 > x {
            newX = -dataViewWidth
        }
        let newEndpoint = CGPoint(x: newX, y: 0)
        targetContentOffset.pointee = newEndpoint
    }
    
    func handleWillGoToIndex(_ idx: Int) {
        UIView.animate(withDuration: 0.5) {
            self.updateColors(forIdx: idx)
        }
    }
    
    func updateColors(forIdx idx: Int) {
        let hasValue = idx != 0
        if hasValue {
            self.contentButton.backgroundColor = self.activeColor
            self.dataViews.forEach({ $0.label.textColor = .akLight.withAlphaComponent(0.7) })
        } else {
            self.contentButton.backgroundColor = self.activeColor?.withAlphaComponent(0.1)
            self.dataViews.forEach({ $0.label.textColor = .akDark })
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateViewsStyle(scrollView)
    }

    private func updateViewsStyle(_ scrollView: UIScrollView) {
        for (i, dataView) in dataViews.enumerated() {
            dataView.respondToScrollView(idx: i, container: scrollView)
        }
    }

    // API

    func getCurrentValue() -> String? {
        guard let dataView = dataViews.first else {
            assertionFailure()
            return nil
        }

        let offset = hScroll.contentOffset.x
        let idx = Int(offset/dataView.frame.width + 1)
        return data[idx]
    }
    
    // Override layoutSubviews to update shadow view's frame
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update shadow view's path if needed
        if let shadowView = shadowView as? ShadowView {
            shadowView.updateShadowPath()
        }
    }
}


final class StepperDataView: UIView {

    // MARK: - Properties

    private var value: String
    var label = UILabel.make(.h2)

    // MARK: - Initializers

    init(frame: CGRect, value: String) {
        self.value = value
        super.init(frame: frame)

        setup()
        addSubviewsAndConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func setup() {
        label.text = value
        label.textColor = .akLight
        label.textAlignment = .center
        label.text = value
        label.isUserInteractionEnabled = false
        label.font = AKFont.round(.black, 30)
        isUserInteractionEnabled = false

        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    func addSubviewsAndConstraints() {
        addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(8)
            make.right.left.equalToSuperview()
        }
    }

    // Takes its position and index in container scrollview to calculate state
    func respondToScrollView(idx: Int, container: UIScrollView) {
        guard (-frame.width...container.contentSize.width).contains(container.contentOffset.x) else { return }

        let cellWidth = container.frame.width/3
        let myCenter = CGFloat(idx)*cellWidth + cellWidth/2
        let offset = container.contentOffset.x
        let centerPointingAt = offset+container.frame.width/2
        let distanceFromCenter = abs(centerPointingAt - myCenter)
        let maxCenterToCenterDistance = cellWidth*1.5
        let normalizedDistanceFromCenter = min(abs(distanceFromCenter), maxCenterToCenterDistance)/maxCenterToCenterDistance
        let maxTranslation: CGFloat = 0
        let translation = maxTranslation*(1-normalizedDistanceFromCenter)

        // Keep regular size at max and scale down when offset from the center
        // This to avoid pixelating font
        let maxScale: CGFloat = 0.5
        let scale = 1 - maxScale*(normalizedDistanceFromCenter)

        alpha = 1-normalizedDistanceFromCenter
        label.transform = CGAffineTransform.identity.translatedBy(x: 0, y: translation).scaledBy(x: scale, y: scale)

        // Shake if exactly at center
        if normalizedDistanceFromCenter == 0 {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
        }
    }
}

protocol AKStepperDelegate {
    func didSelectValue(_ string: String)
}

// Add an extension to ensure ShadowView can update its shadow path
extension ShadowView {
    func updateShadowPath() {
        // This method should update the shadow path based on the current bounds
        // If ShadowView already has this functionality, you can leave this empty
        // Otherwise, implement shadow path updating logic here
    }
}








public class ShadowView: UIView {

    // MARK: - Properties

    var offset: CGSize = CGSize(width: 0, height: 0)
    var radius: CGFloat = 30
    var opacity: Float = 0.2
    var color: UIColor = UIColor.black
    var cornerRadius: Float = 0.0
    var isCircle: Bool = false
    var showOnlyOutsideBounds: Bool = false

    // MARK: - Layout

    override public func layoutSubviews() {
        super.layoutSubviews()

        var cornerRadius = self.cornerRadius
        if isCircle {
            cornerRadius = Float(min(frame.height, frame.width) / 2.0)
        }

        if showOnlyOutsideBounds {
            let maskLayer = CAShapeLayer()
            let path = CGMutablePath()
            path.addPath(UIBezierPath(roundedRect: bounds.inset(by: UIEdgeInsets.zero), cornerRadius: CGFloat(cornerRadius)).cgPath)
            path.addPath(UIBezierPath(roundedRect: bounds.inset(by: UIEdgeInsets(top: -offset.height - radius*2, left: -offset.width - radius*2, bottom: -offset.height - radius*2, right: -offset.width - radius*2)), cornerRadius: CGFloat(cornerRadius)).cgPath)
            maskLayer.backgroundColor = UIColor.black.cgColor
            maskLayer.path = path;
            maskLayer.fillRule = .evenOdd
            self.layer.mask = maskLayer
        } else {
            self.layer.masksToBounds = false
        }

        self.layer.shadowOffset = self.offset
        self.layer.shadowRadius = self.radius
        self.layer.shadowOpacity = self.opacity
        self.layer.shadowColor = self.color.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: CGFloat(cornerRadius)).cgPath
    }
}
