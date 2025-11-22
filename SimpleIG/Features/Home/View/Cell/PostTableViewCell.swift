import UIKit
import Kingfisher

class PostTableViewCell: UITableViewCell {

    static let identifier = "PostTableViewCell"
    var likeButtonAction: (() -> Void)?
    var shareButtonAction: (() -> Void)?
    var sendCommentAction: ((String) -> Void)?

    var commnets: [Comment] = []
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 18
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.tintColor = .white
        return iv
    }()

    private let usernameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 14)
        return lbl
    }()

    private let moreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        btn.tintColor = .label
        return btn
    }()

    private let postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        return iv
    }()

    private let likeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
        btn.tintColor = .label
        return btn
    }()
    
    var isLiked: Bool = false {
        didSet {
            let imageName = isLiked ? "heart.fill" : "heart"
            likeButton.setImage(UIImage(systemName: imageName), for: .normal)
            likeButton.tintColor = isLiked ? .systemRed : .label
        }
    }

    private let commentButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        btn.tintColor = .label
        return btn
    }()

    let shareButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "paperplane"), for: .normal)
        btn.tintColor = .label
        return btn
    }()

    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "bookmark"), for: .normal)
        btn.tintColor = .label
        return btn
    }()

    private let likeCountLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 14)
        return lbl
    }()

    private let captionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14)
        lbl.numberOfLines = 0
        return lbl
    }()

    private let viewCommentsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("View all comments", for: .normal)
        btn.setTitleColor(.secondaryLabel, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13)
        btn.contentHorizontalAlignment = .left
        return btn
    }()

    private let timeLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    private let commentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Add a comment..."
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        return tf
    }()

    private let sendCommentButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Send", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 14)
        return btn
    }()

    private lazy var commentBar: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [commentTextField, sendCommentButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.isHidden = true
        return stack
    }()
    
    private let commentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .systemBackground
        setupLayout()
        setupActions()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentStack)

        let topBar = UIStackView(arrangedSubviews: [profileImageView, usernameLabel, UIView(), moreButton])
        topBar.axis = .horizontal
        topBar.spacing = 8
        topBar.alignment = .center
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 36),
            profileImageView.heightAnchor.constraint(equalToConstant: 36)
        ])

        let actionBar = UIStackView(arrangedSubviews: [likeButton, commentButton, shareButton, UIView(), saveButton])
        actionBar.axis = .horizontal
        actionBar.spacing = 12
        actionBar.alignment = .center

        [topBar, postImageView, actionBar, likeCountLabel, captionLabel, commentStackView, viewCommentsButton, commentBar, timeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentStack.addArrangedSubview($0)
        }

        NSLayoutConstraint.activate([
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor),

            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    private func setupActions() {
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        sendCommentButton.addTarget(self, action: #selector(didTapSendComment), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapPostImage))
        doubleTap.numberOfTapsRequired = 2
        postImageView.addGestureRecognizer(doubleTap)
    }

    func configure(with post: Post, commnets: [Comment]) {
        usernameLabel.text = post.ownerName ?? "Anonymous"
        captionLabel.text = post.caption
        likeCountLabel.text = "\(post.likeCount) likes"
        timeLabel.text = post.timestamp.formattedString
        postImageView.setImage(from: post.imageUrl, placeholderSystemName: "photo.slash")
        profileImageView.setImage(from: post.ownerImage, placeholderSystemName: "person.crop.circle")

        let uid = DefaultManager.shared.get(DefaultManager.uid) ?? ""
        isLiked = post.likes.contains { $0 == uid }
        
        self.commnets = commnets
        reloadComments()
    }

    private func reloadComments() {
        commentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if commnets.isEmpty {
            viewCommentsButton.setTitle("No comments yet", for: .normal)
            return
        }
        
        viewCommentsButton.setTitle("View all \(commnets.count) comments", for: .normal)
        
        let commentsToShow = commnets.suffix(2)
        
        for comment in commentsToShow {
            let lbl = UILabel()
            lbl.numberOfLines = 0
            lbl.font = .systemFont(ofSize: 11)

            let bold = "\(comment.ownerName) "
            let normal = comment.text

            let attributedText = NSMutableAttributedString(
                string: bold,
                attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 11)
                ]
            )

            attributedText.append(NSAttributedString(
                string: normal,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 11)
                ]
            ))

            lbl.attributedText = attributedText
            commentStackView.addArrangedSubview(lbl)
        }
        
        if let tableView = self.superview as? UITableView {
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }
    
    @objc private func didTapLike() {
        likeButtonAction?()
    }

    @objc private func didDoubleTapPostImage() {
        if !isLiked {
            didTapLike()
            animateHeart()
        }
    }
    
    func updateLikeCount() {
        let likeCount = Int(likeCountLabel.text?.replacing(" likes", with: "") ?? "0") ?? 0
        likeCountLabel.text = "\(isLiked ? (likeCount + 1) : (likeCount - 1)) likes"
    }

    @objc private func didTapShare() {
        shareButtonAction?()
    }

    @objc private func didTapCommentButton() {
        commentBar.isHidden.toggle()
        if let tableView = self.superview as? UITableView {
               UIView.animate(withDuration: 0.25) {
                   tableView.beginUpdates()
                   tableView.endUpdates()
               }
           }
    }

    @objc private func didTapSendComment() {
        guard let text = commentTextField.text, !text.isEmpty else { return }
        sendCommentAction?(text)
        commentTextField.text = ""
        commentBar.isHidden = true
    }

    private func animateHeart() {
        let heart = UIImageView(image: UIImage(systemName: "heart.fill"))
        heart.tintColor = .white
        heart.alpha = 0
        heart.translatesAutoresizingMaskIntoConstraints = false
        postImageView.addSubview(heart)

        NSLayoutConstraint.activate([
            heart.centerXAnchor.constraint(equalTo: postImageView.centerXAnchor),
            heart.centerYAnchor.constraint(equalTo: postImageView.centerYAnchor),
            heart.widthAnchor.constraint(equalToConstant: 100),
            heart.heightAnchor.constraint(equalToConstant: 100)
        ])

        UIView.animate(withDuration: 0.1, animations: {
            heart.alpha = 1
            heart.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveEaseOut, animations: {
                heart.alpha = 0
                heart.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion: { _ in
                heart.removeFromSuperview()
            })
        }
    }
}
