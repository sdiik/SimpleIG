import UIKit
import Combine
import WebKit

final class ProfilePhotoViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    private let viewModel = ProfilePhotoViewModel()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 60
        iv.backgroundColor = .lightGray
        iv.tintColor = .white
        return iv
    }()

    private let usernameLabel = UILabel()
    private let fullnameLabel = UILabel()
    private let bioLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.textColor = .systemGray
        lbl.font = .systemFont(ofSize: 14)
        return lbl
    }()
    private let createdAtLabel = UILabel()

    private let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Welcome to your profile! Here you can manage your account and check FAQs."
        lbl.font = .systemFont(ofSize: 14)
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.textColor = .systemGray
        return lbl
    }()

    private let changePhotoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Change Photo", for: .normal)
        return btn
    }()

    private let logoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Logout", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        return btn
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.hidesWhenStopped = true
        return ai
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
        bindViewModel()
    }

    private func setupUI() {
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

        let stack = UIStackView(arrangedSubviews: [
            profileImageView,
            changePhotoButton,
            usernameLabel,
            fullnameLabel,
            bioLabel,
            createdAtLabel,
            descriptionLabel,
            logoutButton
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),

            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])

        contentView.addSubview(loadingIndicator)
        loadingIndicator.center = contentView.center
    }

    private func setupActions() {
        changePhotoButton.addTarget(self, action: #selector(didTapChangePhoto), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.$username
            .sink { [weak self] in self?.usernameLabel.text = "@\($0)" }
            .store(in: &cancellables)

        viewModel.$fullname
            .sink { [weak self] in self?.fullnameLabel.text = $0 }
            .store(in: &cancellables)

        viewModel.$bio
            .sink { [weak self] in self?.bioLabel.text = $0 }
            .store(in: &cancellables)

        viewModel.$createdAt
            .sink { [weak self] in self?.createdAtLabel.text = "Joined \($0 ?? "-")" }
            .store(in: &cancellables)

        viewModel.$profileImageUrl
            .sink { [weak self] urlString in
                self?.profileImageView.setImage(
                    from: urlString,
                    placeholderSystemName: "person.circle"
                )
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .sink { [weak self] loading in
                loading ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .sink { [weak self] message in
                guard !message.isEmpty else { return }
                self?.showAlert(title: "Error", message: message)
            }
            .store(in: &cancellables)
    }

    @objc private func didTapChangePhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    @objc private func didTapLogout() {
        DefaultManager.shared.clear()
        navigationController?.popToRootViewController(animated: true)
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
}

extension ProfilePhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage) else { return }
        profileImageView.image = image
        Task { await viewModel.uploadProfilePhoto(image: image) }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

