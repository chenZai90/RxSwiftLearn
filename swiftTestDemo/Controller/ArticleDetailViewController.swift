import UIKit
import SafariServices
import RxSwift

class ArticleDetailViewController: UIViewController {
    
    private let disposeBag = DisposeBag()

    private var article: Article?
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
        
//        if self.article == nil {
            
            self.article = Article(
                id: "1",
                title: "科技革新：AI 正在如何改变医疗行业",
                summary: "随着人工智能的发展，医疗行业正在经历前所未有的变革。本文将深入探讨 AI 在诊断、药物开发及患者护理中的应用。",
                content: "AI 技术正逐步渗透到医疗诊断、个性化治疗、临床辅助决策等多个环节，提高效率与准确率的同时，也引发了伦理与隐私等方面的讨论。",
                imageUrl: "https://images.unsplash.com/photo-1588776814546-c43c2f49a15d", // Unsplash 高质量医疗类图像
                contentHTML: """
                    <h2>AI 赋能医疗诊断</h2>
                    <p>近年来，AI 在影像识别和疾病预测方面取得了显著进展。许多医院已部署 AI 辅助系统进行早期癌症筛查、糖尿病视网膜病变识别等。</p>

                    <img src="https://images.unsplash.com/photo-1600880292089-90a7e086ee38" alt="AI医疗图像" style="max-width:100%; border-radius:8px; margin: 16px 0;" />

                    <p>例如，Google Health 的 AI 模型在乳腺癌筛查中表现出超过人类放射科医生的准确率。</p>

                    <h3>药物研发加速</h3>
                    <p>AI 不仅可分析庞大的化合物数据，还能预测潜在的药物反应，大幅缩短新药从实验到上市的周期。</p>
                    <ul>
                      <li>利用深度学习筛选活性分子</li>
                      <li>通过模拟预测临床试验成功率</li>
                      <li>降低研发成本和失败率</li>
                    </ul>

                    <img src="https://images.unsplash.com/photo-1581090700227-1e8e9082206d" alt="药物分析图" style="max-width:100%; border-radius:8px; margin: 16px 0;" />

                    <h3>挑战与未来</h3>
                    <p>尽管前景广阔，但 AI 在医疗中的广泛应用仍面临算法偏差、数据隐私、伦理审查等挑战。</p>

                    <blockquote>“AI 不会取代医生，但会取代那些不会使用 AI 的医生。” —— 医疗科技专家</blockquote>
                    
                    <p>未来，我们期待构建一个技术与人文并重的智能医疗生态。</p>
                """,
                isFavorited: false
            )
//        }
        
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
//        openButton.addTarget(self, action: #selector(openInSafari), for: .touchUpInside)
        
        
        
        openButton.rx.tap.subscribe(onNext:  { [weak self] in
            
//            guard let url = URL(string: self?.article?.imageUrl ?? "") else { return }
//            let safari = SFSafariViewController(url: url)
//            self?.present(safari, animated: true)
            
            // 获取图片链接
            guard let article = self?.article,
                  let urlString = article.imageUrl,
                  let url = URL(string: urlString) else {
                print("❌ URL 无效")
                return
            }

            // 检查是否为模拟器
            #if targetEnvironment(simulator)
            // 模拟器环境：弹出提示
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "模拟器限制",
                    message: "iOS 模拟器不支持 SFSafariViewController，请在真机上测试。",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "知道了", style: .default))
                self?.present(alert, animated: true)
            }
            #else
            // 真机环境：正常打开 Safari
            DispatchQueue.main.async {
                let safariVC = SFSafariViewController(url: url)
                safariVC.delegate = self // 如果需要监听关闭事件，记得设置 delegate
                self?.present(safariVC, animated: true)
            }
            #endif

            
            
            
        }).disposed(by: disposeBag)
        
        
        
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
        titleLabel.text = article?.title
        contentLabel.text = article?.summary
    }

//    @objc private func openInSafari() {
//        guard let url = URL(string: article.imageUrl) else { return }
//        let safari = SFSafariViewController(url: url)
//        present(safari, animated: true)
//    }
}

