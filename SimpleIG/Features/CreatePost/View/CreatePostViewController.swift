import UIKit
import PhotosUI

final class CreatePostViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Create a Post"
        lbl.font = .boldSystemFont(ofSize: 28)
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Share your moments with your followers"
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = .systemGray
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = UIColor(white: 0.95, alpha: 1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.image = UIImage(systemName: "photo.on.rectangle")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = .systemGray
        return iv
    }()
    
    private let captionTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.layer.cornerRadius = 12
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray5.cgColor
        tv.isScrollEnabled = false
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        return tv
    }()
    
    private let shareButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Share Post", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.tintColor = .white
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 12
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return btn
    }()
    
    private let loadingOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isHidden = true
        
        let ai = UIActivityIndicatorView(style: .large)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.startAnimating()
        overlay.addSubview(ai)
        
        NSLayoutConstraint.activate([
            ai.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            ai.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])
        
        return overlay
    }()
    
    private let viewModel = CreatePostViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isHidden = true
        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.prefersLargeTitles = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        [titleLabel, descriptionLabel, imageView, captionTextView, shareButton].forEach { contentView.addSubview($0); $0.translatesAutoresizingMaskIntoConstraints = false }
        view.addSubview(loadingOverlay)
        
        NSLayoutConstraint.activate([
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            imageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            captionTextView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            captionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            captionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            captionTextView.heightAnchor.constraint(equalToConstant: 120),
            
            shareButton.topAnchor.constraint(equalTo: captionTextView.bottomAnchor, constant: 24),
            shareButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            shareButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            shareButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        imageView.addGestureRecognizer(tapGesture)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
    }

    @objc private func didTapImage() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func didTapShare() {
        guard let image = imageView.image else {
            showMessage(title: "Error", message: "Please select an image")
            return
        }
        
        let caption = captionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !caption.isEmpty else {
            showMessage(title: "Error", message: "Caption cannot be empty")
            return
        }

        loadingOverlay.isHidden = false
        shareButton.isEnabled = false

        Task {
            await viewModel.uploadPost(image: image, caption: caption)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.loadingOverlay.isHidden = true
                self.shareButton.isEnabled = true

                if let error = self.viewModel.errorMessage {
                    self.showMessage(title: "Error", message: error)
                } else {
                    self.showMessage(title: "Success", message: "Post uploaded successfully") {
                        self.imageView.image = UIImage(systemName: "photo.on.rectangle")?.withRenderingMode(.alwaysTemplate)
                        self.imageView.tintColor = .systemGray
                        self.captionTextView.text = ""
                        
                        if let tabBarController = self.tabBarController as? MainTabBarController {
                            NotificationCenter.default.post(name: .didCreateNewPost, object: nil)
                            tabBarController.selectedIndex = 0
                        }
                    }
                }
            }
        }
    }

    private func showMessage(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

extension CreatePostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            DispatchQueue.main.async {
                self?.imageView.image = image as? UIImage
            }
        }
    }
}
