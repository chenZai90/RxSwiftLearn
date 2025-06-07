import Foundation
import RxSwift
import RxCocoa

class HomeViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let networkService = NetworkService()
    
    // MARK: - Inputs
    let searchText = BehaviorRelay<String>(value: "")
    let selectedTabIndex = BehaviorRelay<Int>(value: 0)
    let refreshTrigger = PublishSubject<Void>()
    let loadMoreTrigger = PublishSubject<Void>()
    
    // MARK: - Outputs
    let items = BehaviorRelay<[FeedItem]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishSubject<Error>()
    
    // MARK: - Private Properties
    private var currentPage = 1
    private var hasMoreData = true
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // 监听搜索文本变化
        searchText
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.refreshData()
            })
            .disposed(by: disposeBag)
        
        // 监听标签选择变化
        selectedTabIndex
            .subscribe(onNext: { [weak self] _ in
                self?.refreshData()
            })
            .disposed(by: disposeBag)
        
        // 监听刷新触发
        refreshTrigger
            .subscribe(onNext: { [weak self] _ in
                self?.refreshData()
            })
            .disposed(by: disposeBag)
        
        // 监听加载更多触发
        loadMoreTrigger
            .subscribe(onNext: { [weak self] _ in
                self?.loadMoreData()
            })
            .disposed(by: disposeBag)
    }
    
    private func refreshData() {
        guard !isLoading.value else { return }
        
        currentPage = 1
        hasMoreData = true
        isLoading.accept(true)
        
        let searchQuery = searchText.value
        let selectedTab = selectedTabIndex.value
        
        networkService.fetchFeedItems(page: currentPage, searchQuery: searchQuery, selectedTab: selectedTab)
            .subscribe(onSuccess: { [weak self] items in
                self?.items.accept(items)
                self?.isLoading.accept(false)
            }, onFailure: { [weak self] error in
                self?.error.onNext(error)
                self?.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    private func loadMoreData() {
        guard !isLoading.value && hasMoreData else { return }
        
        isLoading.accept(true)
        currentPage += 1
        
        let searchQuery = searchText.value
        let selectedTab = selectedTabIndex.value
        
        networkService.fetchFeedItems(page: currentPage, searchQuery: searchQuery, selectedTab: selectedTab)
            .subscribe(onSuccess: { [weak self] newItems in
                guard let self = self else { return }
                
                if newItems.isEmpty {
                    self.hasMoreData = false
                } else {
                    var currentItems = self.items.value
                    currentItems.append(contentsOf: newItems)
                    self.items.accept(currentItems)
                }
                
                self.isLoading.accept(false)
            }, onFailure: { [weak self] error in
                self?.error.onNext(error)
                self?.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
} 