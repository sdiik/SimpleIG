import UIKit

final class LoginViewController: UIViewController {
    private lazy var titleLabel = makeTitleLabel("Welcome Back!")
    private lazy var descriptionLabel = makeDescriptionLabel("Sign in to continue using the app")
    private lazy var emailTextField = makeTextField(placeholder: "Email", keyboardType: .emailAddress)
    private lazy var passwordTextField = makeTextField(placeholder: "Password", isSecure: true)
    private lazy var loginButton = makePrimaryButton(title: "Login", color: .systemBlue)
    private lazy var googleLoginButton = makePrimaryButton(title: "Login with Google", color: .white)
    private lazy var signupButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Don't have an account? Sign Up", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(.systemBlue, for: .normal)
        return btn
    }()
    private lazy var errorLabel = makeErrorLabel()
    private lazy var activityIndicator = makeActivityIndicator()
    
    private lazy var stackView = makeStackView(arrangedSubviews: [
        titleLabel,
        descriptionLabel,
        emailTextField,
        passwordTextField,
        activityIndicator,
        loginButton,
        //googleLoginButton,
        signupButton,
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
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        googleLoginButton.addTarget(self, action: #selector(googleLoginTapped), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
    }
    
    @objc private func loginTapped() {
        vm.email = emailTextField.text ?? ""
        vm.password = passwordTextField.text ?? ""
        
        errorLabel.isHidden = true
        activityIndicator.startAnimating()
        loginButton.isEnabled = false
        
        Task {
            await vm.login()
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.loginButton.isEnabled = true
                if !self.vm.errorMessage.isEmpty {
                    self.errorLabel.text = self.vm.errorMessage
                    self.errorLabel.isHidden = false
                } else {
                    let homeVC = MainTabBarController()
                    self.navigationController?.pushViewController(homeVC, animated: true)
                }
            }
        }
    }
    
    @objc private func googleLoginTapped() {
        errorLabel.isHidden = true
        activityIndicator.startAnimating()
        googleLoginButton.isEnabled = false
        
        Task {
            do {
                try await vm.loginGoogle(presentingVC: self)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.googleLoginButton.isEnabled = true
                    let homeVC = HomeViewController()
                    self.navigationController?.pushViewController(homeVC, animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.googleLoginButton.isEnabled = true
                    self.errorLabel.text = error.localizedDescription
                    self.errorLabel.isHidden = false
                }
            }
        }
    }
    
    @objc private func signupTapped() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
}
