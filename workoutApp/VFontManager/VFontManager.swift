import UIKit
import AKKIT
import VFont

final public class VFontShowcaseVC: UIViewController {

    // MARK: - Properties

    private var allVFonts = [VFonts.inter(size: 24)]
    private var fontExamples = [UILabel]()
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .center
        stack.axis = .vertical
        stack.distribution = .fillEqually
        return stack
    }()

    var timer = Timer()
    var tick = 0.01
    var currentTickerValue = 0.5
    var isTimerRunning = false

    // MARK: - Initializers

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        addSubviewsAndConstraints()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runTimer()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }

    // MARK: - Methods

    private func setup() {
        view.backgroundColor = .akLight

        for font in allVFonts {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: Screen.width, height: 100))
            label.text = font.variableFontName
            fontExamples.append(label)
            stack.addArrangedSubview(label)
        }
    }

    private func addSubviewsAndConstraints() {
        view.addSubview(stack)
        view.backgroundColor = .akLight
        stack.frame = UIScreen.main.bounds
    }

    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1/100, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    // Tick from 0 to 1 with autoreverse
    @objc func updateTimer() {
        let minValue: Double = 0
        let maxValue: Double = 1
        if currentTickerValue >= maxValue || currentTickerValue <= minValue {
            tick = tick * -1
        }

        currentTickerValue += tick
        currentTickerValue = currentTickerValue.clamped(to: 0...1)

        for label in fontExamples.enumerated() {
            let index = label.0
            let currentLabel = label.1
            let newFont = allVFonts[index].make(weight: CGFloat(currentTickerValue))
            currentLabel.font = newFont
            currentLabel.textAlignment = .center
        }
    }

    // MARK: - Animate Word in String

    func animateWordInString(_ string: String, targetWord: String, duration: TimeInterval) {
        let attributedString = NSMutableAttributedString(string: string)
        let range = (string as NSString).range(of: targetWord)
        guard range.location != NSNotFound else {
            print("Word not found in string.")
            return
        }

        // Initial normal weight
        let normalFont = allVFonts[0].make(weight: 0) // Normal weight
        attributedString.addAttribute(.font, value: normalFont, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.font, value: normalFont, range: range)

        // Create a UILabel to display the animated text
        let animatedLabel = UILabel()
        animatedLabel.attributedText = attributedString
        animatedLabel.textAlignment = .center
        animatedLabel.frame = CGRect(x: 0, y: 0, width: Screen.width, height: 100)
        
        // Add the label to the stack
        stack.addArrangedSubview(animatedLabel)

        // Animate the font weight
        let steps: CGFloat = 10
        let stepDuration = duration / Double(steps)

        for i in 0...Int(steps) {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                // Calculate the weight for the variable font
                let weight = CGFloat(i) / steps // Normalize to [0, 1]
                let newFont = self.allVFonts[0].make(weight: weight) // Use the first font for animation
                
                // Update the attributed string with the new font for the target word
                attributedString.addAttribute(.font, value: newFont, range: range)
                animatedLabel.attributedText = attributedString
            }
        }
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
