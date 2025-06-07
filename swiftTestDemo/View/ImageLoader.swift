import UIKit
import RxSwift

class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func loadImage(from urlString: String) -> Observable<UIImage?> {
        return Observable.create { [weak self] observer in
            // 检查缓存
            if let cachedImage = self?.cache.object(forKey: urlString as NSString) {
                observer.onNext(cachedImage)
                observer.onCompleted()
                return Disposables.create()
            }
            
            // 检查URL
            guard let url = URL(string: urlString) else {
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create()
            }
            
            // 创建下载任务
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let data = data,
                      let image = UIImage(data: data) else {
                    observer.onNext(nil)
                    observer.onCompleted()
                    return
                }
                
                // 存入缓存
                self?.cache.setObject(image, forKey: urlString as NSString)
                
                observer.onNext(image)
                observer.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
} 