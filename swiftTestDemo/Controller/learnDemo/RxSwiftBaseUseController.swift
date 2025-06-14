//
//  RxSwiftBaseUseController.swift
//  swiftTestDemo
//
//  Created by jcmac on 2025/6/14.
//


/**
 这里的代码示例来源于官方文档，自己只是在研究使用方式的时候完善了一下代码。
 像作者致敬，详细的请移步中文文档https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/why_rxswift.html。
 
 */

import UIKit
import SnapKit
import RxSwift
class RxSwiftBaseUseController: UIViewController {
        
    private let disposeBag = DisposeBag()
    private let scrollerView = UIScrollView()
    let teacherId = 1001
    
    lazy var testBtn: UIButton = {
        let btn: UIButton = UIButton(type: .custom)
        btn.setTitle("测试1", for: .normal)
        btn.titleLabel?.textColor = .red
        btn.backgroundColor = .blue
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
        self.test1()
        self.test2()
        self.test3()
        self.test4()
        self.test5()
        self.test6()
        self.test7()
        self.test8()
        scrollerView.delegate = self
        
    }
    

    func test4() {
        let observable = Observable<String>.create { observer in
            observer.onNext("Hello")
            observer.onNext("World")
            observer.onCompleted()
            return Disposables.create()
        }

        observable.subscribe { event in
            switch event {
            case .next(let value):
                print("Received: $value)")
            case .error(let error):
                print("Error: $error)")
            case .completed:
                print("Completed")
            }
        }.disposed(by: disposeBag)
    }
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - UIScrollViewDelegate 添加单例
extension RxSwiftBaseUseController  {
    
    func test3(){
        
        NotificationCenter.default.rx
            .notification(UIApplication.willEnterForegroundNotification)
               .subscribe(onNext: { (notification) in
                   print("Application Will Enter Foreground")
               })
               .disposed(by: disposeBag)
        
        
        NotificationCenter.default.rx
                   .notification(UIApplication.willEnterForegroundNotification)
                   .observe(on: MainScheduler.instance)
                   .subscribe(onNext: { _ in
                       print("Application is about to enter foreground")
                   })
                   .disposed(by: disposeBag)
        
    }
    
    
}


//MARK: - UIScrollViewDelegate 添加单例
extension RxSwiftBaseUseController: UIScrollViewDelegate {
     ///传统写法
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
          print("传统：：：contentOffset: \(scrollView.contentOffset)")
      }
    
    func test2(){
        self.scrollerView.rx.contentOffset
                  .subscribe(onNext: { contentOffset in
                      print("contentOffset: \(contentOffset)")
                  })
                  .disposed(by: disposeBag)
    }
    
    
}

//MARK: - 给UIBUtton添加点击事件
extension RxSwiftBaseUseController {
    
    func test1(){//传统
        view.addSubview(self.testBtn)
        self.testBtn.snp.makeConstraints { make in
            make.top.equalTo(self.view).offset(50)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSize(width: 60, height: 40))
        }
        
        ///传统
        self.testBtn.addTarget(self, action: #selector(testMethond), for: UIControl.Event.touchUpInside)
        
        //Rxswfit
        self.testBtn.rx.tap
            .subscribe(onNext: {
                print("button Tapped")
            })
            .disposed(by: disposeBag)
    }
    
    @objc func testMethond(){
        let user = User()
        print(user.name ?? "")   // 输出: John
        print(user.age ?? "")    // 输出: 25
        print(user.gender ?? "nil") // 输出: nil
    }
    
    
}

/// @dynamicMemberLookup 基础用法
extension RxSwiftBaseUseController {
    
    @dynamicMemberLookup
    struct User {
        private var data: [String: Any] = [
            "name": "John",
            "age": 25,
            "email": "john@example.com"
        ]

        subscript(dynamicMember member: String) -> Any? {
            return data[member]
        }
    }

}



//MARK: - rx 封装网络接口

enum RxAPI {
    /// 通过用户名密码取得一个 token
    static func token(username: String, password: String) -> Observable<String> {
        // 使用 just 创建一个包含模拟 token 的 Observable
        return Observable.just("1234")
    }

    /// 通过 token 取得用户信息
    static func userInfo(token: String) -> Observable<UserInfo> {
        // 使用 just 创建一个包含模拟用户信息的 Observable
        return Observable.just(UserInfo(token:"122233",username: "John Doe", password: "123"))
    }
}

struct UserInfo {
    var token: String
    var username: String
    var password: String
}

extension RxSwiftBaseUseController {
    
    
    
    func test5(){
        /// 通过用户名和密码获取用户信息
        RxAPI.token(username: "beeth0ven", password: "987654321")
            .flatMapLatest(RxAPI.userInfo)
            .subscribe(onNext: { userInfo in
                print("获取用户信息成功: \(userInfo)")
            }, onError: { error in
                print("获取用户信息失败: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    
}


//MARK: - 等待多个并发任务完成后处理结果


// 老师信息模型
struct Teacher {
    let id: Int
    let name: String
    let subject: String
}

// 评论模型
struct Comment {
    let id: Int
    let content: String
    let author: String
}


enum RxTeacherAPI {
    /// 取得老师的详细信息
    static func teacher(teacherId: Int) -> Observable<Teacher> {
        // 模拟网络请求（成功）
        return Observable.just(Teacher(
            id: teacherId,
            name: "张老师",
            subject: "数学"
        )).delay(.milliseconds(1000), scheduler: ConcurrentMainScheduler.instance)
    }

    /// 取得老师的评论
    static func teacherComments(teacherId: Int) -> Observable<[Comment]> {
        // 模拟网络请求（成功）
        let comments: [Comment] = [
            Comment(id: 1, content: "讲解清晰", author: "学生A"),
            Comment(id: 2, content: "幽默风趣", author: "学生B")
        ]
        
        // 模拟网络请求（失败）
        // return Observable.error(NSError(domain: "CommentError", code: 1, userInfo: nil))
        
        return Observable.just(comments)
            .delay(.milliseconds(800), scheduler: ConcurrentMainScheduler.instance)
    }
}


extension RxSwiftBaseUseController {
    
    func test6() {
        // 使用 zip 合并两个请求
        Observable.zip(
            RxTeacherAPI.teacher(teacherId: teacherId),
            RxTeacherAPI.teacherComments(teacherId: teacherId)
        )
            // 错误处理
        .catch { error in
                print("全局错误捕获: $error)")
                return Observable.empty()
            }
            // 确保在主线程更新 UI
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { (teacher, comments) in
                    print("获取老师信息成功: $teacher.name)，科目: $teacher.subject)")
                    print("获取老师评论成功: $comments.count) 条")
                },
                onError: { error in
                    print("获取老师信息或评论失败: $error)")
                },
                onCompleted: {
                    print("请求完成")
                }
            )
            .disposed(by: disposeBag)
    }
    
    
    
    func test7(){


        let disposeBag = DisposeBag()

        // 冷 Observable（每次订阅重新执行）
        let cold = Observable<Int>.create { observer in
            observer.onNext(1)
            return Disposables.create()
        }

        // 热 Observable（共享事件流）
        let hot = PublishSubject<Int>()
        hot.onNext(2)

        // 订阅冷 Observable
        cold.subscribe(onNext: { value in
            print("Cold: $value)")  // ✅ 正确使用参数
        })
        .disposed(by: disposeBag)

        // 订阅热 Observable
        hot.subscribe(onNext: { value in
            print("Hot: $value)")  // ✅ 正确使用参数
        })
        .disposed(by: disposeBag)
    }
    
    
    func test8(){
        let numbers: Observable<Int> = Observable.create { observer -> Disposable in

            observer.onNext(0)
            observer.onNext(1)
            observer.onNext(2)
            observer.onNext(3)
            observer.onNext(4)
            observer.onNext(5)
            observer.onNext(6)
            observer.onNext(7)
            observer.onNext(8)
            observer.onNext(9)
            observer.onCompleted()

            return Disposables.create()
        }
        
        print("\(numbers)")
    }
 
    
    
    
    
}


//MARK: - single 使用

// 定义错误类型
enum FileReadError: Error {
    case fileNotFound(String)
    case invalidJSON(String)
}


// 定义用户模型
struct RxUser {
    let username: String
    let token: String
}

// 自定义错误类型
enum AuthError: Error {
    case invalidCredentials
}

extension RxSwiftBaseUseController {
    
    // 创建 Single：读取并解析本地 JSON 文件
    func loadJSON(from filename: String) -> Single<[String: Any]> {
        return Single.create { single in
            let filePath = Bundle.main.path(forResource: filename, ofType: "json")!
            
            // 读取文件内容
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                
                // 解析 JSON
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        single(.success(json)) // 成功返回解析结果
                    } else {
                        single(.failure(FileReadError.invalidJSON("无法解析 JSON 数据")))
                    }
                } catch {
                    single(.failure(FileReadError.invalidJSON("JSON 解析失败: $error)")))
                }
            } catch {
                single(.failure(FileReadError.fileNotFound("文件未找到: $filename)")))
            }
            
            return Disposables.create {} // 无需额外资源释放
        }
    }
    
    
    // 创建 Single：模拟用户登录
    func login(username: String, password: String) -> Single<RxUser> {
        return Single.create { single in
            // 模拟网络请求延迟
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
                if username == "admin" && password == "123456" {
                    // ✅ 正确创建 User 实例（结构体名修正为 User）
                    let user = RxUser(username: "admin", token: "123456")
                    single(.success(user)) // 使用 .success 表示成功
                } else {
                    // ✅ 修正为 Single 的 .error 方法（而非 Result 的 .failure）
                    single(.failure(AuthError.invalidCredentials))
                }
            }
            
            // 返回可释放资源（无需额外操作）
            return Disposables.create {}
        }
    }
    
 
    }





