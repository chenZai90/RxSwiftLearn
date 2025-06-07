import Foundation

struct FeedItem {
    enum ItemType {
        case newsArticle
        case video
        case jobPosting
    }
    
    let type: ItemType
    let title: String
    let source: String
    let timeAgo: String
    let imageUrl: String?
} 