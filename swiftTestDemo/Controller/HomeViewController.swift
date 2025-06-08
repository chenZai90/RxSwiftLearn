
import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = HomeViewModel()
    private var isLoadingMore = false
    private var hasMoreData = true

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
        tableView.rowHeight = 84
        tableView.estimatedRowHeight = 84
        return tableView
    }()

    private let refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "下拉刷新")
        return refresh
    }()

    private let loadingMoreView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "上拉加载更多"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        view.addSubview(label)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -40),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: activityIndicator.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: activityIndicator.centerYAnchor)
        ])

        return view
    }()

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(customSearchBar)
        view.addSubview(slidingTabBarView)
        view.addSubview(feedTableView)
        feedTableView.refreshControl = refreshControl

        NSLayoutConstraint.activate([
            customSearchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            customSearchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            customSearchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            customSearchBar.heightAnchor.constraint(equalToConstant: 36),

            slidingTabBarView.topAnchor.constraint(equalTo: customSearchBar.bottomAnchor, constant: 8),
            slidingTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            slidingTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            slidingTabBarView.heightAnchor.constraint(equalToConstant: 44),

            feedTableView.topAnchor.constraint(equalTo: slidingTabBarView.bottomAnchor),
            feedTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            feedTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            feedTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupBindings() {
        // 搜索绑定
        customSearchBar.searchText
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)

        customSearchBar.isSearching
            .subscribe(onNext: { [weak self] isSearching in
                UIView.animate(withDuration: 0.3) {
                    self?.slidingTabBarView.alpha = isSearching ? 0 : 1
                    self?.slidingTabBarView.transform = isSearching ? CGAffineTransform(translationX: 0, y: -20) : .identity
                }
            })
            .disposed(by: disposeBag)

        // 下拉刷新
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.hasMoreData = true
                self?.viewModel.refreshTrigger.onNext(())
            })
            .disposed(by: disposeBag)

        // 加载状态绑定
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                    self?.isLoadingMore = false
                }
            })
            .disposed(by: disposeBag)

        // 数据源绑定（只绑定 UI，不处理分页）
        viewModel.items
            .bind(to: feedTableView.rx.items(cellIdentifier: "FeedItemCell", cellType: FeedItemCell.self)) { row, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)

        // 分页逻辑：仅在加载更多时评估 hasMoreData
        viewModel.items
            .skip(1) // 跳过初始 8 条数据
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.hasMoreData = items.count >= 8
                self?.feedTableView.tableFooterView = self?.hasMoreData == true ? self?.loadingMoreView : nil
                self?.isLoadingMore = false
            })
            .disposed(by: disposeBag)

        // 上拉加载更多
        feedTableView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] _, indexPath in
                guard let self = self else { return }
                let lastRow = self.feedTableView.numberOfRows(inSection: 0) - 1
                if indexPath.row == lastRow - 1 && !self.isLoadingMore && self.hasMoreData {
                    self.loadMoreData()
                }
            })
            .disposed(by: disposeBag)

        // 错误处理
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showError(error)
            })
            .disposed(by: disposeBag)

        // 标签栏点击
        slidingTabBarView.itemSelected
            .bind(to: viewModel.selectedTabIndex)
            .disposed(by: disposeBag)

        // 单元格点击事件
        feedTableView.rx.itemSelected
            
            .subscribe(onNext: { [weak self] indexPath in
                self?.feedTableView.deselectRow(at: indexPath, animated: true)
                
                self?.jumpToVc(index: indexPath.row)
            })
            .disposed(by: disposeBag)
        
        
    }
    
    
    
    

    // MARK: - Helper Methods
    private func loadMoreData() {
        guard !isLoadingMore && hasMoreData else { return }
        isLoadingMore = true
        feedTableView.tableFooterView = loadingMoreView
        viewModel.loadMoreTrigger.onNext(())
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "错误",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}


extension HomeViewController {
    
    func jumpToVc(index: Int) {
        
        switch index {
        case 0:
            
            self.navigationController?.pushViewController(ArticleListViewController.init(), animated: true)
            
            break;
        case 1:
            
            
            self.navigationController?.pushViewController(NewsDetailViewController.init(), animated: true)
            
            break;
            

        default:
            print("=====")
        }
    }
}
