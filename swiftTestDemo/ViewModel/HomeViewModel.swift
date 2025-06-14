import Foundation
import RxSwift
import RxCocoa

class HomeViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // 输入
    let refreshTrigger = PublishSubject<Void>()
    let loadMoreTrigger = PublishSubject<Void>()
    let selectedTabIndex = BehaviorRelay<Int>(value: 0)
    let searchText = BehaviorRelay<String>(value: "")
    
    // 输出
    let items: BehaviorRelay<[FeedItem]> = BehaviorRelay(value: [])
    let isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let error: PublishSubject<Error> = PublishSubject()
    
    // 私有属性
    private var currentPage = 1
    private var hasMoreData = true
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // 处理刷新
        refreshTrigger
            .do(onNext: { [weak self] _ in
                self?.currentPage = 1
                self?.hasMoreData = true
                self?.isLoading.accept(true)
            })
            .flatMap { [weak self] _ -> Observable<[FeedItem]> in
                guard let self = self else { return .empty() }
                return self.fetchData(page: self.currentPage)
            }
            .subscribe(onNext: { [weak self] items in
                self?.items.accept(items)
                self?.isLoading.accept(false)
            }, onError: { [weak self] error in
                self?.error.onNext(error)
                self?.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
        
        // 处理加载更多
        loadMoreTrigger
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return !self.isLoading.value && self.hasMoreData
            }
            .do(onNext: { [weak self] _ in
                self?.currentPage += 1
                self?.isLoading.accept(true)
            })
            .flatMap { [weak self] _ -> Observable<[FeedItem]> in
                guard let self = self else { return .empty() }
                return self.fetchData(page: self.currentPage)
            }
            .subscribe(onNext: { [weak self] newItems in
                guard let self = self else { return }
                var currentItems = self.items.value
                currentItems.append(contentsOf: newItems)
                self.items.accept(currentItems)
                self.isLoading.accept(false)
            }, onError: { [weak self] error in
                self?.error.onNext(error)
                self?.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
        
        // 处理标签切换
        selectedTabIndex
            .distinctUntilChanged()
            .do(onNext: { [weak self] _ in
                self?.currentPage = 1
                self?.hasMoreData = true
                self?.isLoading.accept(true)
            })
            .flatMap { [weak self] index -> Observable<[FeedItem]> in
                guard let self = self else { return .empty() }
                return self.fetchData(page: 1, tabIndex: index)
            }
            .subscribe(onNext: { [weak self] items in
                self?.items.accept(items)
                self?.isLoading.accept(false)
            }, onError: { [weak self] error in
                self?.error.onNext(error)
                self?.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
        
        // 处理搜索
        searchText
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .do(onNext: { [weak self] _ in
                self?.currentPage = 1
                self?.hasMoreData = true
                self?.isLoading.accept(true)
            })
            .flatMap { [weak self] searchText -> Observable<[FeedItem]> in
                guard let self = self else { return .empty() }
                return self.fetchData(page: 1, searchText: searchText)
            }
            .subscribe(onNext: { [weak self] items in
                self?.items.accept(items)
                self?.isLoading.accept(false)
            }, onError: { [weak self] error in
                self?.error.onNext(error)
                self?.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchData(page: Int, tabIndex: Int? = nil, searchText: String? = nil) -> Observable<[FeedItem]> {
        // 这里应该是实际的网络请求
        // 现在用模拟数据代替
        return Observable.create { observer in
            // 模拟网络延迟
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let items = self.generateMockData()
                observer.onNext(items)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    private func generateMockData() -> [FeedItem] {
        let imageUrls = [
            "https://picsum.photos/200/300",
            "https://picsum.photos/200/301",
            "https://picsum.photos/200/302",
            "https://picsum.photos/200/303",
            "https://picsum.photos/200/304"
        ]
        
        return [
            FeedItem(type: .newsArticle, 
                    title: "新闻标题 \(Int.random(in: 1...100))", 
                    source: "新闻来源", 
                    timeAgo: "\(Int.random(in: 1...60))分钟前", 
                    imageUrl: imageUrls.randomElement()),
            FeedItem(type: .video, 
                    title: "视频标题 \(Int.random(in: 1...100))", 
                    source: "视频来源", 
                    timeAgo: "\(Int.random(in: 1...60))分钟前", 
                    imageUrl: imageUrls.randomElement()),
            FeedItem(type: .jobPosting, 
                    title: "招聘信息 \(Int.random(in: 1...100))", 
                    source: "招聘来源", 
                    timeAgo: "\(Int.random(in: 1...60))分钟前", 
                    imageUrl: imageUrls.randomElement()),
            FeedItem(type: .jobPosting,
                    title: "招聘信息 \(Int.random(in: 1...100))",
                    source: "招聘来源",
                    timeAgo: "\(Int.random(in: 1...60))分钟前",
                    imageUrl: imageUrls.randomElement()),
            FeedItem(type: .jobPosting,
                    title: "招聘信息 \(Int.random(in: 1...100))",
                    source: "招聘来源",
                    timeAgo: "\(Int.random(in: 1...60))分钟前",
                    imageUrl: imageUrls.randomElement()),
            FeedItem(type: .newsArticle,
                    title: "新闻标题 \(Int.random(in: 1...100))",
                    source: "新闻来源",
                    timeAgo: "\(Int.random(in: 1...60))分钟前",
                    imageUrl: imageUrls.randomElement()),
            FeedItem(type: .video,
                    title: "视频标题 \(Int.random(in: 1...100))",
                    source: "视频来源",
                    timeAgo: "\(Int.random(in: 1...60))分钟前",
                    imageUrl: imageUrls.randomElement()),
            FeedItem(type: .jobPosting,
                    title: "招聘信息 \(Int.random(in: 1...100))",
                    source: "招聘来源",
                    timeAgo: "\(Int.random(in: 1...60))分钟前",
                    imageUrl: imageUrls.randomElement())
        ]
    }
    
//MARK: - 测试跳转的界面
    func allControllers() -> [UIViewController]? {
        
        return [ArticleListViewController.init(),
                NewsDetailViewController.init(),
                RxSwiftBaseUseController.init()
               ]
    }
}
