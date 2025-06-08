import Foundation
import RxSwift
import RxCocoa

// MARK: - ViewModel
class ArticleListViewModel {
    
    // MARK: - Output
    let articles: BehaviorRelay<[Article]> = BehaviorRelay(value: [])
    let selectedArticle = PublishSubject<Article>()
    let error = PublishSubject<Error>()
    let isLoading = BehaviorRelay<Bool>(value: false) // 加载状态
    
    // MARK: - Private Properties
    private let disposeBag = DisposeBag()
    private let articleService: ArticleService
    
    // MARK: - Initialization
    init(articleService: ArticleService = FakeArticleService()) {
        self.articleService = articleService
    }
    
    // MARK: - Public Methods
    
    /// 开始加载文章数据
    func fetchArticles() {
        isLoading.accept(true)
        
        articleService.fetchArticles()
            .observe(on: MainScheduler.instance) // 确保主线程更新
            .do(onNext: { [weak self] _ in
                self?.isLoading.accept(false)
            }, onError: { [weak self] _ in
                self?.isLoading.accept(false)
            })
            .subscribe(
                onNext: { [weak self] fetchedArticles in
                    self?.articles.accept(fetchedArticles)
                },
                onError: { [weak self] networkError in
                    self?.error.onNext(networkError)
                }
            )
            .disposed(by: disposeBag)
    }
}

// MARK: - ArticleService Protocol
protocol ArticleService {
    func fetchArticles() -> Observable<[Article]>
}

// MARK: - FakeArticleService (模拟数据源)
class FakeArticleService: ArticleService {
    func fetchArticles() -> Observable<[Article]> {
        return Observable.create { observer in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.4) {
                if Bool.random() {
                    let fakeArticles = self.generateFakeArticles()
                    observer.onNext(fakeArticles)
                    observer.onCompleted()
                } else {
                    let networkError = NSError(domain: "Network", code: 500, userInfo: [
                        NSLocalizedDescriptionKey: "加载失败，请检查网络连接"
                    ])
                    observer.onError(networkError)
                }
            }
            return Disposables.create()
        }
    }
    
    private func generateFakeArticles() -> [Article] {
        return [
            Article(
                id: "1",
                title: "全球气候变化：2025年我们面临的挑战与机遇",
                summary: "随着极端天气频发，气候科学家警告全球变暖带来的连锁反应，包括海平面上升、农作物减产以及生态系统崩溃。",
                content: "近年来，全球气温持续上升，2024年是有记录以来最热的一年。科学家指出，如果不采取有效措施，到本世纪末全球平均气温可能会上升超过2°C。这将导致冰川融化、海平面上升，并影响数百万人的生活。",
                imageUrl: "https://images.unsplash.com/photo-1581090763669-f3c8d9595eac?auto=format&fit=crop&w=800&q=80",
                contentHTML: "<h2>全球气候变化</h2><p>近年来，全球气温持续上升，2024年是有记录以来最热的一年。</p><ul><li>极端天气事件增加</li><li>北极冰层加速融化</li><li>农业产量面临下降风险</li></ul>",
                isFavorited: false
            ),
            Article(
                id: "2",
                title: "人工智能如何改变医疗行业？",
                summary: "AI技术正在被广泛应用于疾病诊断、药物研发和个性化治疗中，成为医疗领域的重要推动力。",
                content: "从早期癌症筛查到智能辅助手术，人工智能正逐步渗透进医疗行业的各个环节。通过深度学习算法，医生可以更快地识别病变区域并制定精准治疗方案。",
                imageUrl: "https://images.unsplash.com/photo-1581091215367-59a9c3ba3f4c?auto=format&fit=crop&w=800&q=80",
                contentHTML: "<h2>AI 改变医疗</h2><p>人工智能在医疗领域的应用日益广泛，以下是几个关键方向：</p><ol><li>图像识别辅助诊断</li><li>预测疾病发展趋势</li><li>自动分析病理报告</li></ol>",
                isFavorited: false
            ),
            Article(
                id: "3",
                title: "元宇宙时代：虚拟世界如何重塑我们的生活",
                summary: "随着VR/AR技术和区块链的发展，元宇宙概念逐渐落地，它不仅改变了游戏产业，还对教育、办公等领域产生了深远影响。",
                content: "元宇宙不再只是科幻小说中的概念。如今，人们可以通过虚拟现实设备进入数字世界，进行社交、工作甚至购物。专家预测，未来十年内，元宇宙将成为互联网的新形态。",
                imageUrl: "https://images.unsplash.com/photo-1620714223084-8fcacc6dfd8d?auto=format&fit=crop&w=800&q=80",
                contentHTML: "<h2>元宇宙时代来临</h2><p>虚拟现实和增强现实技术的进步推动了元宇宙的发展：</p><ul><li>虚拟会议系统</li><li>沉浸式在线教育</li><li>数字身份与资产确权</li></ul>",
                isFavorited: false
            ),
            Article(
                id: "4",
                title: "可持续能源的未来：太阳能与风能的崛起",
                summary: "面对化石燃料资源枯竭和环境污染问题，清洁能源正成为全球能源结构转型的核心。",
                content: "太阳能和风能在过去十年中得到了广泛应用。随着电池存储技术的进步，这些可再生能源的稳定性也大幅提高。许多国家已制定了碳中和目标，并加大对绿色能源的投资。",
                imageUrl: "https://images.unsplash.com/photo-1597922301945-9a5b76ccee2f?auto=format&fit=crop&w=800&q=80",
                contentHTML: "<h2>清洁能源的崛起</h2><p>太阳能与风能的优势：</p><ul><li>减少温室气体排放</li><li>降低长期能源成本</li><li>促进就业和经济发展</li></ul>",
                isFavorited: false
            ),
            Article(
                id: "5",
                title: "数字隐私安全：你真的了解你的数据去哪了吗？",
                summary: "随着越来越多的应用收集用户数据，个人隐私保护变得越来越重要。各国政府也在加强立法以保障网络安全。",
                content: "每天我们都在使用各种App，但很少有人知道自己的数据是如何被使用的。专家建议，应定期检查权限设置，避免不必要的信息泄露。",
                imageUrl: "https://images.unsplash.com/photo-1607746882042-944635dfe10e?auto=format&fit=crop&w=800&q=80",
                contentHTML: "<h2>数字隐私安全</h2><p>以下是一些保护隐私的小技巧：</p><ul><li>关闭非必要的定位权限</li><li>使用双重认证</li><li>定期更新密码</li></ul>",
                isFavorited: false
            )
        ]
    }
}
