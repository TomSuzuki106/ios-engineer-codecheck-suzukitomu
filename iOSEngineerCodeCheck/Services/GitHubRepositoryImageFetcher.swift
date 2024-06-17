//
//  GitHubRepositoryImageFetcher.swift
//  iOSEngineerCodeCheck
//
//  Created by 鈴木斗夢 on 2024/06/17.
//  Copyright © 2024 YUMEMI Inc. All rights reserved.
//

import UIKit

protocol GitHubRepositoryImageFetching {
    func fetchRepositoryImage(from urlString: String, completion: @escaping (Result<UIImage?, Error>) -> Void)
}

class GitHubRepositoryImageFetcher: GitHubRepositoryImageFetching {    
    func fetchRepositoryImage(from urlString: String, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        guard let imgURL = URL(string: urlString) else {
            let error = NSError(domain: "Invalid URL", code: -1, userInfo: nil)
            completion(.failure(error))
            return
        }
        fetchImage(from: imgURL, completion: completion)
    }

    private func fetchImage(from url: URL, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data, let img = UIImage(data: data) {
                completion(.success(img))
            } else {
                completion(.success(nil))
            }
        }.resume()
    }
}
