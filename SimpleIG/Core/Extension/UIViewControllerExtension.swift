import UIKit

extension UIViewController {
    
    func makeTitleLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 32, weight: .bold)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }
    
    func makeDescriptionLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }
    
    func makeTextField(placeholder: String, isSecure: Bool = false, keyboardType: UIKeyboardType = .default) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = isSecure
        tf.keyboardType = keyboardType
        tf.autocapitalizationType = .none
        return tf
    }
    
    func makePrimaryButton(title: String, color: UIColor = .systemBlue) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = color
        btn.tintColor = .white
        btn.layer.cornerRadius = 8
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return btn
    }
    
    func makeErrorLabel() -> UILabel {
        let lbl = UILabel()
        lbl.textColor = .systemRed
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.isHidden = true
        return lbl
    }
    
    func makeActivityIndicator(style: UIActivityIndicatorView.Style = .medium) -> UIActivityIndicatorView {
        let ai = UIActivityIndicatorView(style: style)
        ai.hidesWhenStopped = true
        return ai
    }
    
    func makeStackView(arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis = .vertical, spacing: CGFloat = 16) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: arrangedSubviews)
        stack.axis = axis
        stack.spacing = spacing
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
}
