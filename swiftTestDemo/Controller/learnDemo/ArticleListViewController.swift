//
//  ArticleListViewController.swift
//  swiftTestDemo
//
//  Created by jcmac on 2025/6/4.
//
import UIKit
import RxSwift
import RxCocoa

class ArticleListViewController: UIViewController {
    
    private let viewModel = ArticleListViewModel()
    private let disposeBag = DisposeBag()
    private var collectionView: UICollectionView!
    private var articles: [Article] = [] // 保存文章数据，供点击事件使用
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "今日新闻"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        bindViewModel()
        viewModel.fetchArticles()
        
        // 绑定点击事件：根据索引值跳转不同页面
        collectionView.rx
            .itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self, indexPath.row < self.articles.count else { return }
                let article = self.articles[indexPath.row]
                
                if indexPath.row == 1 {
                    // 索引为 1，跳转到 NewsDetailViewController
                    let vc = NewsDetailViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                    
                } else {
                    // 其他索引，跳转到 ArticleDetailViewController
                    let detailVC = ArticleDetailViewController(article: article)
                    self.navigationController?.pushViewController(detailVC, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(ArticleCell.self, forCellWithReuseIdentifier: ArticleCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let columns = traitCollection.horizontalSizeClass == .compact ? 1 : 2
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(130))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: columns)

        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func bindViewModel() {
        viewModel.articles
            .observe(on: MainScheduler.instance)
            .bind(to: collectionView.rx.items(cellIdentifier: ArticleCell.identifier, cellType: ArticleCell.self)) { index, article, cell in
                cell.configure(with: article)
            }
            .disposed(by: disposeBag)
        
        // 将 articles 更新到本地变量，供点击事件使用
        viewModel.articles
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] articles in
                self?.articles = articles
            })
            .disposed(by: disposeBag)
    }
}

