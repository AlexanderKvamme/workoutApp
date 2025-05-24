import UIKit
import AKKIT
import VFont

final public class VFTextViewAnimator: UIViewController {

    // MARK: - Properties

    private var textView: UITextView!
    
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
        
        setupTextView()
    }

    // MARK: - Methods

    private func setupTextView() {
        view.backgroundColor = .akLight 

        // Initialize the UITextView
        textView = UITextView(frame: view.bounds)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .white
        textView.textAlignment = .center
        view.addSubview(textView)
    }

    func animateWordInTextView(_ string: String = "This is a fucking test brev", targetWord: String = "fucking", duration: TimeInterval = 0.5) {
        let attributedString = NSMutableAttributedString(string: string)
        let range = (string as NSString).range(of: targetWord)
        guard range.location != NSNotFound else {
            print("Word not found in string.")
            return
        }

        // Set the initial font (normal weight)
        attributedString.addAttribute(.font, value: vfontFront, range: NSRange(location: 0, length: attributedString.length))
        
        // Set the initial font for the target word
        attributedString.addAttribute(.font, value: vfontFront, range: range)

        // Set the attributed text to the text view
        textView.attributedText = attributedString

        // Animate the font weight
        let steps: CGFloat = 10
        let stepDuration = duration / Double(steps)

        for i in 0...Int(steps) {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                // Calculate the weight for the variable font
                let weight = CGFloat(i) / steps // Normalize to [0, 1]
                let newFont = vfontFront.make(weight: weight)
                // Update the attributed string with the new font for the target word
                attributedString.addAttribute(.font, value: newFont, range: range)
                self.textView.attributedText = attributedString
            }
        }
    }
}
