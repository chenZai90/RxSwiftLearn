import UIKit
import RxSwift

class FeedItemCell: UITableViewCell {
    // MARK: - UI Components
    private let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    private var currentImageURL: String?
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .systemBackground
        
        // 添加子视图
        contentView.addSubview(itemImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(sourceLabel)
        contentView.addSubview(timeLabel)
        
        // 设置约束
        NSLayoutConstraint.activate([
            // 图片视图约束
            itemImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            itemImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            itemImageView.widthAnchor.constraint(equalToConstant: 80),
            itemImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // Title 约束
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: itemImageView.leadingAnchor, constant: -12),
            
            // Source 约束
            sourceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            sourceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // Time 约束
            timeLabel.centerYAnchor.constraint(equalTo: sourceLabel.centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: sourceLabel.trailingAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: itemImageView.leadingAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    func configure(with item: FeedItem) {
        titleLabel.text = item.title
        sourceLabel.text = item.source
        timeLabel.text = item.timeAgo
        
        if let imageUrl = item.imageUrl {
            if currentImageURL != imageUrl {
                currentImageURL = imageUrl
                loadImage(from: imageUrl)
            }
        } else {
            itemImageView.image = nil
            currentImageURL = nil
        }
    }
    
    private func loadImage(from urlString: String) {
        ImageLoader.shared.loadImage(from: urlString)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                if self?.currentImageURL == urlString {
                    self?.itemImageView.image = image
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        itemImageView.image = nil
        currentImageURL = nil
        titleLabel.text = nil
        sourceLabel.text = nil
        timeLabel.text = nil
    }
} 