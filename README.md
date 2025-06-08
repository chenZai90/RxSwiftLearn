# RxSwiftLearn

一个用于学习和实践 **RxSwift** 框架的项目，专注于掌握 iOS 开发中的响应式编程。该项目通过实际案例帮助开发者理解响应式编程的核心概念，并将其应用于实际场景中。
---

## 🚀 项目概述

**RxSwiftLearn** 旨在帮助开发者掌握 [RxSwift](https://github.com/ReactiveX/RxSwift) 的基础知识和高级特性。通过实践案例、代码片段和详细注释，演示如何构建响应式、异步和事件驱动的应用程序。

---

## 📦 功能特点

- **RxSwift 核心概念**：  
  - 可观察对象（Observable）、观察者（Observer）和订阅（Subscription）  
  - 操作符（map、filter、flatMap 等）  
  - 主题（Subjects）和变量（Variables）  
  - 错误处理与资源释放  

- **实际应用场景**：  
  - 异步网络请求  
  - 使用 `UITextField` 和 `UITableView` 的数据绑定  
  - 响应式表单验证  
  - 多数据流的组合  

- **最佳实践**：  
  - 结构化响应式代码以提高可读性  
  - 使用 `DisposeBag` 管理内存  
  - 通过 `Scheduler` 控制线程调度  

---

## 🛠️ 安装指南

### 依赖要求
- Xcode 14+  
- Swift 5.0+  
- iOS 13.0+  

### 依赖管理

#### CocoaPods
在 `Podfile` 中添加以下内容：
```ruby
pod 'RxSwift'
pod 'RxCocoa'
```

#### Swift Package Manager
1. 在 Xcode 中选择 **文件 > 添加包...**  
2. 输入仓库地址：  
   `https://github.com/ReactiveX/RxSwift.git`  
3. 选择最新版本并添加到项目中。

---

## 📄 示例代码

### 基础可观察对象
```swift
let disposeBag = DisposeBag()

// 创建一个可观察序列
let numbers = Observable.of(1, 2, 3, 4, 5)

// 订阅事件
numbers
    .subscribe(onNext: { value in
        print("接收到值: $value)")
    }, onError: { error in
        print("错误: $error)")
    }, onCompleted: {
        print("序列已完成")
    })
    .disposed(by: disposeBag)
```

### 响应式文本绑定
```swift
import RxCocoa

// 将文本框输入绑定到标签
textField.rx.text
    .orEmpty
    .subscribe(onNext: { text in
        self.titleLabel.text = "你好, $text)!"
    })
    .disposed(by: disposeBag)
```


---

#### 部分项目截图 
  ![项目截图1](https://github.com/chenZai90/RxSwiftLearn/blob/main/screenshots/1.png)
    ![项目截图2](https://github.com/chenZai90/RxSwiftLearn/blob/main/screenshots/2.png)
      ![项目截图3](https://github.com/chenZai90/RxSwiftLearn/blob/main/screenshots/3.png)

---

## 📚 参考资料

- [RxSwift GitHub 仓库](https://github.com/ReactiveX/RxSwift)    


---

让响应式编程变得简单有趣！🌟
