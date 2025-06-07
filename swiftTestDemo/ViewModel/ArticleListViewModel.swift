import Foundation
import RxSwift
import RxCocoa

class ArticleListViewModel {
    
    // MARK: - Output
    let articles: BehaviorRelay<[Article]> = BehaviorRelay(value: [])
    let selectedArticle = PublishSubject<Article>()
    let error = PublishSubject<Error>()
    
    // MARK: - Private Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    func fetchArticles() {
        // 使用 DispatchWorkItem 包装闭包
        let workItem = DispatchWorkItem {
            if Bool.random() {
                let fakeArticles = [
                    Article(
                        id: "1",
                        title: "新闻 1",
                        summary: "这是摘要 1",
                        content: "这是正文 1",
                        imageUrl: "https://example.com/image1.jpg",
                        contentHTML: "<p>内容1</p>",
                        isFavorited: false
                    ),
                    Article(
                        id: "2",
                        title: "新闻 2",
                        summary: "这是摘要 2",
                        content: "这是正文 2",
                        imageUrl: "https://example.com/image2.jpg",
                        contentHTML: "<p>内容2</p>",
                        isFavorited: false
                    )
                ]
                DispatchQueue.main.async {
                    self.articles.accept(fakeArticles)
                }
            } else {
                let networkError = NSError(domain: "Network", code: 500, userInfo: [NSLocalizedDescriptionKey: "加载失败"])
                DispatchQueue.main.async {
                    self.error.onNext(networkError)
                }
            }
        }

        // 延迟执行任务
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: workItem)
    }
    
    
}
