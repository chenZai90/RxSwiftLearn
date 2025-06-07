import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = HomeViewModel()
    
    // MARK: - UI Components
    private let customSearchBar: CustomSearchBar = {
        let searchBar = CustomSearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let slidingTabBarView: SlidingTabBarView = {
        let tabBar = SlidingTabBarView()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        return tabBar
    }()
    
    private let feedTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.register(FeedItemCell.self, forCellReuseIdentifier: "FeedItemCell")
        return tableView
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(customSearchBar)
        view.addSubview(slidingTabBarView)
        view.addSubview(feedTableView)
        
        // Setup refresh control
        feedTableView.refreshControl = refreshControl
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Custom search bar constraints
            customSearchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            customSearchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            customSearchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            customSearchBar.heightAnchor.constraint(equalToConstant: 36),
            
            // SlidingTabBarView constraints
            slidingTabBarView.topAnchor.constraint(equalTo: customSearchBar.bottomAnchor, constant: 8),
            slidingTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            slidingTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            slidingTabBarView.heightAnchor.constraint(equalToConstant: 44),
            
            // FeedTableView constraints
            feedTableView.topAnchor.constraint(equalTo: slidingTabBarView.bottomAnchor),
            feedTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            feedTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            feedTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        // 绑定搜索栏
        customSearchBar.searchText
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        // 绑定搜索状态
        customSearchBar.isSearching
            .subscribe(onNext: { [weak self] isSearching in
                UIView.animate(withDuration: 0.3) {
                    self?.slidingTabBarView.alpha = isSearching ? 0 : 1
                    self?.slidingTabBarView.transform = isSearching ? CGAffineTransform(translationX: 0, y: -20) : .identity
                }
            })
            .disposed(by: disposeBag)
        
        // 绑定刷新控制
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.refreshTrigger)
            .disposed(by: disposeBag)
        
        // 绑定加载状态
        viewModel.isLoading
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        // 绑定数据源
        viewModel.items
            .bind(to: feedTableView.rx.items(cellIdentifier: "FeedItemCell", cellType: FeedItemCell.self)) { row, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)
        
        // 绑定加载更多
        feedTableView.rx.didScroll
            .map { [weak self] _ -> Bool in
                guard let self = self else { return false }
                let offsetY = self.feedTableView.contentOffset.y
                let contentHeight = self.feedTableView.contentSize.height
                let screenHeight = self.feedTableView.frame.size.height
                return offsetY > contentHeight - screenHeight * 1.5
            }
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.loadMoreTrigger.onNext(())
            })
            .disposed(by: disposeBag)
        
        // 绑定错误处理
        viewModel.error
            .subscribe(onNext: { [weak self] error in
                // 处理错误，例如显示提示框
                print("Error: \(error)")
            })
            .disposed(by: disposeBag)
        
        // 绑定标签选择
        slidingTabBarView.itemSelected
            .bind(to: viewModel.selectedTabIndex)
            .disposed(by: disposeBag)
        
        // 绑定单元格点击
        feedTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.feedTableView.deselectRow(at: indexPath, animated: true)
                // 处理单元格点击事件
            })
            .disposed(by: disposeBag)
    }
} 