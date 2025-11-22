import UIKit

extension UIButton {
    static func icon(systemName: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: systemName), for: .normal)
        btn.tintColor = .label
        return btn
    }
}
