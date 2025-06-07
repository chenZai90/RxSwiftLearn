import UIKit
import RxSwift
import RxCocoa

class CustomSearchBar: UIView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    let searchText = BehaviorRelay<String>(value: "")
    let isSearching = BehaviorRelay<Bool>(value: false)
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let searchIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "搜索"
        textField.font = .systemFont(ofSize: 16)
        textField.returnKeyType = .search
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("取消", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.tintColor = .systemRed
        button.alpha = 0
        return button
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupBindings()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(searchIconImageView)
        containerView.addSubview(searchTextField)
        addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 36),
            
            // Search icon constraints
            searchIconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            searchIconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            searchIconImageView.widthAnchor.constraint(equalToConstant: 20),
            searchIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Search text field constraints
            searchTextField.leadingAnchor.constraint(equalTo: searchIconImageView.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            searchTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Cancel button constraints
            cancelButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 44)
        ])
        
        // Add tap gesture to container view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(containerViewTapped))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    private func setupBindings() {
        // Bind text field text to searchText
        searchTextField.rx.text.orEmpty
            .bind(to: searchText)
            .disposed(by: disposeBag)
        
        // Bind cancel button tap
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.endSearching()
            })
            .disposed(by: disposeBag)
        
        // Bind return key
        searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.searchTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    @objc private func containerViewTapped() {
        beginSearching()
    }
    
    private func beginSearching() {
        isSearching.accept(true)
        searchTextField.becomeFirstResponder()
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.cancelButton.alpha = 1
            self?.containerView.backgroundColor = .systemBackground
            self?.containerView.layer.borderWidth = 1
            self?.containerView.layer.borderColor = UIColor.systemRed.cgColor
        })
    }
    
    private func endSearching() {
        isSearching.accept(false)
        searchTextField.resignFirstResponder()
        searchTextField.text = ""
        searchText.accept("")
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.cancelButton.alpha = 0
            self?.containerView.backgroundColor = .systemGray6
            self?.containerView.layer.borderWidth = 0
        })
    }
} 