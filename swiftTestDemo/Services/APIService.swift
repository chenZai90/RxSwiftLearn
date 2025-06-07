//
//  APIService.swift
//  swiftTestDemo
//
//  Created by jcmac on 2025/6/4.
//


import Foundation
import RxSwift

// MARK: - 2. APIError 定义
enum APIError: Error {
    case networkError
    case decodingError
    case unknownError
}

// MARK: - 3. APIService 模拟请求


final class APIService {
    static let shared = APIService()

    private init() {}
    
    

    func fetchArticles() -> Observable<[Article]> {
        return Observable<[Article]>.create { observer in
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                 
                let mockArticles = [
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
                observer.onNext(mockArticles)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}


