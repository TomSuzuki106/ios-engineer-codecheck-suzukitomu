//
// RepositoryModel.swift
//  iOSEngineerCodeCheck
//
//  Created by 鈴木斗夢 on 2024/06/16.
//  Copyright © 2024 YUMEMI Inc. All rights reserved.
//


struct RepositoriesResponse: Codable {
    let items: [RepositoryModel]
}


struct RepositoryModel: Codable {
    let fullName: String
    let language: String?
    let stargazersCount: Int
    let watchersCount: Int
    let forksCount: Int
    let openIssuesCount: Int
    let owner: Owner
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case language
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
        case owner
    }
}

struct Owner: Codable {
    let avatarURL: String
    enum CodingKeys: String, CodingKey {
        case avatarURL = "avatar_url"
    }
}
