import UIKit

class ArticleCell: UICollectionViewCell {
    static let identifier = "ArticleCell"
    
    private let titleLabel = UILabel()
    private let summaryLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        setupSubviews()
    }
    
    private func setupSubviews() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 2
        
        summaryLabel.font = UIFont.systemFont(ofSize: 14)
        summaryLabel.textColor = .secondaryLabel
        summaryLabel.numberOfLines = 3
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, summaryLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with article: Article) {
        titleLabel.text = article.title
        summaryLabel.text = article.summary
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
