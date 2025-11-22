import UIKit

extension UILabel {
    static func bold(size: CGFloat) -> UILabel {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: size)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }

    static func secondary(size: CGFloat) -> UILabel {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: size)
        lbl.textColor = .secondaryLabel
        return lbl
    }
}
