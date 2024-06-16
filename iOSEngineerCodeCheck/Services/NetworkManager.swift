//
//  NetworkManager.swift
//  iOSEngineerCodeCheck
//
//  Created by 鈴木斗夢 on 2024/06/16.
//  Copyright © 2024 YUMEMI Inc. All rights reserved.
//

import UIKit

class NetworkManager {
    private var searchTask: URLSessionTask?
    
    // シングルトンパターンを利用するためNetworkManagerクラスのインスタン化を禁止
    private init() {}
    static let shared = NetworkManager()
    
    func searchRepositories(with searchTerm: String, completion: @escaping (Result<[RepositoryModel], Error>) -> Void) {
        let searchAPIURLString = "https://api.github.com/search/repositories?q=\(searchTerm)"
        guard let searchAPIURL = URL(string: searchAPIURLString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        searchTask = URLSession.shared.dataTask(with: searchAPIURL) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "Data is nil", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let repositoriesResponse = try decoder.decode(RepositoriesResponse.self, from: data)
                let repositories = repositoriesResponse.items
                completion(.success(repositories))
            } catch {
                completion(.failure(error))
            }
        }
        searchTask?.resume()
    }
    
    func cancelSearch() {
        searchTask?.cancel()
    }
    func fetchRepositoryImage(from urlString: String, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        guard let imgURL = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: imgURL) { data, _, error in
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
