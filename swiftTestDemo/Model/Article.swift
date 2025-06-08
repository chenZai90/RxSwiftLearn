//
//  Article.swift
//  swiftTestDemo
//
//  Created by jcmac on 2025/6/4.
//
// MARK: - 1. Article 模型
import Foundation
struct Article: Codable, Identifiable {
    var id: String
    let title: String
    let summary: String
    let content: String
    let imageUrl: String?
    let contentHTML: String
    let isFavorited: Bool
    
    
}


