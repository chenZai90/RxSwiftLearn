import UIKit
import SafariServices

class ArticleDetailViewController: UIViewController {
    
    private let article: Article

    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let openButton = UIButton(type: .system)
    
    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
        title = "文章详情"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        configureWithArticle()
    }
    
    private func setupViews() {
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        titleLabel.numberOfLines = 0
        
        contentLabel.font = UIFont.preferredFont(forTextStyle: .body)
        contentLabel.numberOfLines = 0
        contentLabel.textColor = .secondaryLabel
        
        openButton.setTitle("在浏览器中打开原文", for: .normal)
        openButton.addTarget(self, action: #selector(openInSafari), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, contentLabel, openButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func configureWithArticle() {
        titleLabel.text = article.title
        contentLabel.text = article.summary
    }

    @objc private func openInSafari() {
        guard let url = URL(string: article.imageUrl) else { return }
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }
}
