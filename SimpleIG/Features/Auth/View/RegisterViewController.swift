import UIKit

final class RegisterViewController: UIViewController {
    private lazy var titleLabel = makeTitleLabel("Create Account")
    private lazy var descriptionLabel = makeDescriptionLabel("Sign up to get started")
    private lazy var emailTextField = makeTextField(placeholder: "Email", keyboardType: .emailAddress)
    private lazy var usernameTextField = makeTextField(placeholder: "Username")
    private lazy var passwordTextField = makeTextField(placeholder: "Password", isSecure: true)
    private lazy var signupButton = makePrimaryButton(title: "Sign Up", color: .systemBlue)
    private lazy var errorLabel = makeErrorLabel()
    private lazy var activityIndicator = makeActivityIndicator()
    
    private lazy var backToLoginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Already have an account? Log in", for: .normal)
        btn.setTitleColor(.systemGray, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        return btn
    }()
    
    private lazy var stackView = makeStackView(arrangedSubviews: [
        titleLabel,
        descriptionLabel,
        emailTextField,
        usernameTextField,
        passwordTextField,
        activityIndicator,
        signupButton,
        backToLoginButton,
        errorLabel
    ], spacing: 12)
    
    private let vm = AuthViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupActions()
    }
    
    private func setupLayout() {
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        signupButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
        backToLoginButton.addTarget(self, action: #selector(didTapBackToLogin), for: .touchUpInside)
    }
    
    @objc private func signupTapped() {
        vm.email = emailTextField.text ?? ""
        vm.username = usernameTextField.text ?? ""
        vm.password = passwordTextField.text ?? ""
        
        errorLabel.isHidden = true
        activityIndicator.startAnimating()
        signupButton.isEnabled = false
        
        Task {
            await vm.register()
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.signupButton.isEnabled = true
                if !self.vm.errorMessage.isEmpty {
                    self.errorLabel.text = self.vm.errorMessage
                    self.errorLabel.isHidden = false
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @objc private func didTapBackToLogin() {
        navigationController?.popViewController(animated: true)
    }
}
