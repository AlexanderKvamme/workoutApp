import UIKit

extension UILabel {
    // hasCharacters
    var hasCharacters: Bool {
        if let text = self.text {
            return text.count > 0
        }
        return false
    }
}
