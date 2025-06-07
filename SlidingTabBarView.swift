import UIKit
import RxSwift
import RxCocoa

class SlidingTabBarView: UIView {
    
    // MARK: - Properties
    // 将 PublishSubject 改为 BehaviorRelay
    let itemSelected = BehaviorRelay<Int>(value: 0)
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsHorizontalScrollIndicator = false
        sv.scrollsToTop = false
        return sv
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 20 // Adjust spacing between items
        sv.alignment = .center
        return sv
    }()
    
    private var buttons: [UIButton] = []
    private var selectedIndex: Int = 0 // Keep track of the selected index
    
    // Example titles from the screenshot
    private let itemTitles = ["关注", "发现", "推荐", "热榜", "北京", "精品课", "视频"]
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16), // Add leading padding
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16), // Add trailing padding
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor) // Ensure stack view height matches scroll view
        ])
        
        addItems()
        updateSelection(at: selectedIndex) // Select the first item initially
    }
    
    private func addItems() {
        for (index, title) in itemTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.tag = index // Use tag to identify the index
            button.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium) // Adjust font as needed
            button.setTitleColor(.gray, for: .normal) // Default color
            button.setTitleColor(.systemRed, for: .selected) // Selected color - adjust to match screenshot
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc private func itemTapped(_ sender: UIButton) {
        let tappedIndex = sender.tag
        if tappedIndex != selectedIndex {
            updateSelection(at: tappedIndex)
            itemSelected.accept(tappedIndex) // 使用 accept 而不是 onNext
        }
    }
    
    private func updateSelection(at index: Int) {
        // Deselect previous button
        if selectedIndex < buttons.count {
            buttons[selectedIndex].isSelected = false
            buttons[selectedIndex].titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium) // Reset font
        }
        
        // Select new button
        if index < buttons.count {
            buttons[index].isSelected = true
            buttons[index].titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold) // Highlight font - adjust as needed
            selectedIndex = index
            
            // Scroll to make the selected item visible if it's not
            scrollToItem(at: index)
        }
    }
    
    private func scrollToItem(at index: Int) {
        guard index < buttons.count else { return }
        let selectedButton = buttons[index]
        let buttonFrame = selectedButton.convert(selectedButton.bounds, to: scrollView)
        let visibleRect = scrollView.bounds
        let targetRect = buttonFrame.insetBy(dx: -40, dy: 0) // Add some padding
        scrollView.scrollRectToVisible(targetRect, animated: true)
    }
    
    // Public method to allow external selection
    func selectItem(at index: Int, animated: Bool = true) {
        guard index < buttons.count && index != selectedIndex else { return }
        updateSelection(at: index)
        itemSelected.accept(index) // 使用 accept 而不是 onNext
    }
} 