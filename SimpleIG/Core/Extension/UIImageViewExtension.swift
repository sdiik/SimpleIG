import UIKit

extension UIImageView {
    static func profileImage(size: CGFloat) -> UIImageView {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = size / 2
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(white: 0.9, alpha: 1)
        iv.tintColor = .white
        return iv
    }
    
    func setImage(
            from urlString: String?,
            placeholderSystemName: String? = nil
    ) {
        let placeholder = placeholderSystemName != nil
        ? UIImage(
            systemName: placeholderSystemName!,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 32)
        )?.withRenderingMode(.alwaysTemplate)
        : nil
        
        self.kf.indicatorType = .activity
        self.kf.setImage(
            with: URL(string: urlString ?? ""),
            placeholder: placeholder,
            options: [.transition(.fade(0.3))]
        )
    }
}
