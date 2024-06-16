//
//  RepositorySearchViewModel.swift
//  iOSEngineerCodeCheck
//
//  Created by 鈴木斗夢 on 2024/06/17.
//  Copyright © 2024 YUMEMI Inc. All rights reserved.
//

import Foundation

protocol RepositorySearchViewModelDelegate: AnyObject {
    func updateRepositories()
    func showError(message: Error)
}

class RepositorySearchViewModel {
    weak var delegate: RepositorySearchViewModelDelegate?
    var searchRepositories: [RepositoryModel] = []
    
    init(delegate: RepositorySearchViewModelDelegate) {
        self.delegate = delegate
    }
    
    func searchRepositories(with searchTerm: String) {
        GitHubRepositorySearcher.shared.searchRepositories(with: searchTerm) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let repositories):
                self.searchRepositories = repositories
                self.delegate?.updateRepositories()
            case .failure(let error):
                self.delegate?.showError(message: error)
            }
        }
    }
    
    func cancelSearch() {
        GitHubRepositorySearcher.shared.cancelSearch()
    }
}
