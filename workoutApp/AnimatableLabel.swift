//
//  AnimatableLabel.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 24/05/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT
import Lottie
import SnapKit
import VFont

// MARK: - AnimatableLabel
class AnimatableLabel: UIView {
    // Text layer for rendering text
    let textLayer = CATextLayer()
    
    // Container view to prevent clipping
    private let containerView = UIView()
    
    // Variable font for animation
    var vfont: VFont? = VFonts.elza(size: 40)
    
    // Text properties
    var textString: String?
    var textFont: UIFont?
    var textColor: UIColor = .white
    
    // Extremely generous padding to prevent any clipping
    private let horizontalPadding: CGFloat = 150  // Massively increased
    private let verticalPadding: CGFloat = 80     // Massively increased
    
    // For tracking original position during animations
    private var originalCenter: CGPoint = .zero
    
    // Animation properties
    private var animationDisplayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval = 0
    private var animationDuration: CFTimeInterval = 0
    private var animationCompletion: (() -> Void)?
    private var targetWord: String?
    private var fullAttributedString: NSMutableAttributedString?
    private var targetWordRange: NSRange?
    
    // Debug properties
    private let debugMode = true
    
    // MARK: - Initializers
    init(text: String, font: UIFont, color: UIColor = .white) {
        super.init(frame: .zero)
        self.textString = text
        self.textFont = font
        self.textColor = color
        
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    deinit {
        stopAnimation()
    }
    
    // MARK: - Setup
    private func setupView() {
        // Set random background colors for debugging
        if debugMode {
            backgroundColor = UIColor(
                red: CGFloat.random(in: 0...0.5),
                green: CGFloat.random(in: 0...0.5),
                blue: CGFloat.random(in: 0...0.5),
                alpha: 0.3
            )
            
            containerView.backgroundColor = UIColor(
                red: CGFloat.random(in: 0...0.5),
                green: CGFloat.random(in: 0...0.5),
                blue: CGFloat.random(in: 0...0.5),
                alpha: 0.3
            )
        } else {
            backgroundColor = .clear
            containerView.backgroundColor = .clear
        }
        
        clipsToBounds = false  // Important: don't clip the view
        
        // Setup container view
        containerView.clipsToBounds = false
        addSubview(containerView)
        
        // Configure text layer
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = .center
        textLayer.isWrapped = true
        textLayer.foregroundColor = textColor.cgColor
        textLayer.masksToBounds = false  // Don't clip the text
        
        // Add a border to the text layer for debugging
        if debugMode {
            textLayer.borderColor = UIColor.red.cgColor
            textLayer.borderWidth = 1.0
        }
        
        if let font = textFont {
            textLayer.font = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
            textLayer.fontSize = font.pointSize
        }
        
        if let text = textString {
            textLayer.string = text
        }
        
        containerView.layer.addSublayer(textLayer)
        
        // Position container view
        containerView.frame = bounds
        
        // Calculate initial size
        sizeToFit()
        
        // Print debug info
        if debugMode {
            print("AnimatableLabel setup - frame: \(frame), bounds: \(bounds)")
            print("Container view frame: \(containerView.frame)")
            print("Text layer frame: \(textLayer.frame)")
        }
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make container view fill the entire bounds
        containerView.frame = bounds
        
        // Center the text layer in the container view
        // Make the text layer slightly smaller than the container to ensure no clipping
        let inset: CGFloat = debugMode ? 5 : 0  // Inset for debugging
        textLayer.frame = containerView.bounds.insetBy(dx: inset, dy: inset)
        
        if debugMode {
            print("AnimatableLabel layoutSubviews - bounds: \(bounds)")
            print("Container view frame: \(containerView.frame)")
            print("Text layer frame: \(textLayer.frame)")
        }
    }
    
    override var intrinsicContentSize: CGSize {
        if let text = textString, let font = textFont {
            let attributes = [NSAttributedString.Key.font: font]
            let size = (text as NSString).boundingRect(
                with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attributes,
                context: nil
            ).size
            
            // Add extremely generous padding
            return CGSize(width: size.width + horizontalPadding, height: size.height + verticalPadding)
        }
        
        return CGSize(width: 300, height: 100)  // Larger default size
    }
    
    override func sizeToFit() {
        let size = intrinsicContentSize
        
        // Store the center point before changing the frame
        let oldCenter = center
        
        // Update frame with new size
        frame = CGRect(origin: frame.origin, size: size)
        
        // If we're not at the initial setup (i.e., during animation), maintain the center
        if oldCenter != .zero {
            center = oldCenter
        }
        
        if debugMode {
            print("AnimatableLabel sizeToFit - new size: \(size), frame: \(frame)")
        }
    }
    
    // MARK: - Public Methods
    func setText(_ text: String) {
        textString = text
        textLayer.string = text
        sizeToFit()
    }
    
    func setFont(_ font: UIFont) {
        textFont = font
        textLayer.font = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        textLayer.fontSize = font.pointSize
        sizeToFit()
    }
    
    func setTextColor(_ color: UIColor) {
        textColor = color
        textLayer.foregroundColor = color.cgColor
    }
    
    // MARK: - Animation Methods
    func startVariableAnimation(duration: TimeInterval = 2.5, completion: (() -> Void)? = nil) {
        guard let text = textString, let vfont = vfont else {
            print("No text or font set")
            return
        }
        
        // Stop any existing animation
        stopAnimation()
        
        // Store original center
        originalCenter = center
        
        // Set up animation parameters
        animationDuration = duration
        animationCompletion = completion
        
        // Pre-calculate the maximum size needed for the animation
        // This helps prevent resizing during animation which can cause jitter
        let maxWeightFont = vfont.make(weight: 1.0)
        let attributes = [NSAttributedString.Key.font: maxWeightFont]
        let maxSize = (text as NSString).boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        ).size
        
        // Set the frame to the maximum size right away with extra padding
        let finalSize = CGSize(
            width: maxSize.width + horizontalPadding,
            height: maxSize.height + verticalPadding
        )
        
        frame = CGRect(
            x: originalCenter.x - finalSize.width/2,
            y: originalCenter.y - finalSize.height/2,
            width: finalSize.width,
            height: finalSize.height
        )
        
        // Update container and text layer frames
        layoutSubviews()
        
        if debugMode {
            print("Animation pre-calculated size: \(finalSize)")
            print("New frame: \(frame)")
        }
        
        // Start the display link for smooth animation
        animationDisplayLink = CADisplayLink(target: self, selector: #selector(updateFontWeight))
        animationDisplayLink?.add(to: .main, forMode: .common)
        animationStartTime = CACurrentMediaTime()
    }
    
    @objc private func updateFontWeight() {
        guard let displayLink = animationDisplayLink, let vfont = vfont else { return }
        
        // Calculate progress (0 to 1)
        let elapsed = CACurrentMediaTime() - animationStartTime
        var progress = CGFloat(elapsed / animationDuration)
        
        // Ensure progress is within bounds
        progress = min(1.0, max(0.0, progress))
        
        // Update font weight based on progress
        let newFont = vfont.make(weight: progress)
        
        // Update the font
        textFont = newFont
        textLayer.font = CTFontCreateWithName(newFont.fontName as CFString, newFont.pointSize, nil)
        
        if debugMode && Int(progress * 10) % 2 == 0 {
            print("Animation progress: \(progress), font weight updated")
        }
        
        // Check if animation is complete
        if progress >= 1.0 {
            stopAnimation()
            if debugMode {
                print("Animation completed")
            }
            animationCompletion?()
        }
    }
    
    func animateWord(targetWord: String, duration: TimeInterval = 0.5, completion: (() -> Void)? = nil) {
        guard let fullText = textString, let vfont = vfont else {
            print("No text or font set")
            return
        }
        
        // Stop any existing animation
        stopAnimation()
        
        // Set up the attributed string
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: targetWord)
        
        guard range.location != NSNotFound else {
            print("Word not found in string.")
            return
        }
        
        // Set the initial font for the entire text
        if let font = textFont {
            attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: attributedString.length))
        }
        
        // Set the text color
        attributedString.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: attributedString.length))
        
        // Store for animation
        self.fullAttributedString = attributedString
        self.targetWord = targetWord
        self.targetWordRange = range
        
        // Set the text layer to use attributed string
        textLayer.string = attributedString
        
        // Store original center
        originalCenter = center
        
        // Pre-calculate the maximum size needed for the animation
        // Create a test attributed string with the maximum weight font
        let testAttributedString = NSMutableAttributedString(attributedString: attributedString)
        let maxWeightFont = vfont.make(weight: 1.0)
        testAttributedString.addAttribute(.font, value: maxWeightFont, range: range)
        
        // Calculate the maximum size
        let maxSize = testAttributedString.size()
        
        // Set the frame to the maximum size right away with extra padding
        let finalSize = CGSize(
            width: maxSize.width + horizontalPadding,
            height: maxSize.height + verticalPadding
        )
        
        frame = CGRect(
            x: originalCenter.x - finalSize.width/2,
            y: originalCenter.y - finalSize.height/2,
            width: finalSize.width,
            height: finalSize.height
        )
        
        // Update container and text layer frames
        layoutSubviews()
        
        if debugMode {
            print("Word animation pre-calculated size: \(finalSize)")
            print("New frame: \(frame)")
        }
        
        // Set up animation parameters
        animationDuration = duration
        animationCompletion = completion
        
        // Start the display link for smooth animation
        animationDisplayLink = CADisplayLink(target: self, selector: #selector(updateWordWeight))
        animationDisplayLink?.add(to: .main, forMode: .common)
        animationStartTime = CACurrentMediaTime()
    }
    
    @objc private func updateWordWeight() {
        guard let displayLink = animationDisplayLink,
              let attributedString = fullAttributedString,
              let range = targetWordRange,
              let vfont = vfont else { return }
        
        // Calculate progress (0 to 1)
        let elapsed = CACurrentMediaTime() - animationStartTime
        var progress = CGFloat(elapsed / animationDuration)
        
        // Ensure progress is within bounds
        progress = min(1.0, max(0.0, progress))
        
        // Create a new attributed string for this frame
        let currentAttributedString = NSMutableAttributedString(attributedString: attributedString)
        
        // Apply the weighted font to the target word
        let newFont = vfont.make(weight: progress)
        currentAttributedString.addAttribute(.font, value: newFont, range: range)
        
        // Update the text layer
        textLayer.string = currentAttributedString
        
        if debugMode && Int(progress * 10) % 2 == 0 {
            print("Word animation progress: \(progress), font weight updated")
        }
        
        // Check if animation is complete
        if progress >= 1.0 {
            stopAnimation()
            if debugMode {
                print("Word animation completed")
            }
            animationCompletion?()
        }
    }
    
    private func stopAnimation() {
        animationDisplayLink?.invalidate()
        animationDisplayLink = nil
    }
    
    // Method to match the AnimatedTextView interface
    func animate(completion: (() -> Void)? = nil) {
        startVariableAnimation(completion: completion)
    }
}

// MARK: - VFont Extension
let weightAxis = 2003265652

extension VFont {
    public func make(weight: CGFloat) -> UIFont {
        var weight = weight
        if weight > 1 {
            weight = weight.normalize(to: 900)
        }
        
        guard weight <= 1 && weight >= 0 else { fatalError("Size out of bounds: \(weight)") }
        guard let fontWeightAxis = axes[weightAxis] else { fatalError("Missing axis") }

        let min = fontWeightAxis.minValue
        let max = fontWeightAxis.maxValue
        let calculatedWeight = min + weight * (max - min).magnitude
        let uiFont = UIFont(name: self.uiFont.fontName, size: self.size)!
        let variations = [weightAxis: calculatedWeight]
        let uiFontDescriptor = UIFontDescriptor(fontAttributes: [.name: uiFont.fontName, kCTFontVariationAttribute as UIFontDescriptor.AttributeName: variations])
        let newFont = UIFont(descriptor: uiFontDescriptor, size: uiFont.pointSize)
        return newFont
    }
}

extension CGFloat {
    func normalize(to max: CGFloat) -> CGFloat {
        return self / max
    }
}

// Extension to calculate size of attributed string
extension NSAttributedString {
    func size() -> CGSize {
        return self.boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
    }
}
