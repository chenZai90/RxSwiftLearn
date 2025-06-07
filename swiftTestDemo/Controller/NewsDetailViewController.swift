import UIKit
import WebKit
import RxSwift
import RxCocoa

class NewsDetailViewController: UIViewController {

    private let webView = WKWebView()
    private let disposeBag = DisposeBag()
    
    // 模拟文章内容，这里你可以后续由 ViewModel 提供
    var htmlContent: String = """
    <html>
        <head>
            <style>
                body { font-family: -apple-system; font-size: 17px; padding: 16px; }
                img { max-width: 100%; height: auto; border-radius: 10px; }
                h1 { font-size: 24px; color: #333; }
                p { line-height: 1.6; color: #555; }
            </style>
        </head>
        <body>
            <h1>新闻标题示例</h1>
            <p>这是一个富文本新闻内容的例子。</p>
            <img src="https://via.placeholder.com/600x300" />
            <p>这段话展示了图文混排的样式。</p>
        </body>
    </html>
    """

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "新闻详情"
        self.view.backgroundColor = .systemBackground
        setupWebView()
        loadHTMLContent()
    }

    private func setupWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadHTMLContent() {
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
