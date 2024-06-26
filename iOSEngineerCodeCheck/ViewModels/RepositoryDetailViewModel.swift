//
//  RepositoryDetailViewModel.swift
//  iOSEngineerCodeCheck
//
//  Created by 鈴木斗夢 on 2024/06/17.
//  Copyright © 2024 YUMEMI Inc. All rights reserved.
//

import UIKit

protocol RepositoryDetailViewModelDelegate: AnyObject {
    func updateRepositoryImage(_ image: UIImage?)
    func showPlaceholderImage()
}

class RepositoryDetailViewModel {
    private let repository: RepositoryModel
    var imageFetcher: GitHubRepositoryImageFetching
    weak var delegate: RepositoryDetailViewModelDelegate?
    
    init(repository: RepositoryModel, delegate: RepositoryDetailViewModelDelegate, imageFetcher: GitHubRepositoryImageFetching) {
        self.repository = repository
        self.delegate = delegate
        self.imageFetcher = imageFetcher
    }
    
    func fetchRepositoryImage() {
        let avatarURL = repository.owner.avatarURL
        imageFetcher.fetchRepositoryImage(from: avatarURL) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let image):
                self.delegate?.updateRepositoryImage(image)
            case .failure:
                self.delegate?.showPlaceholderImage()
            }
        }
    }
}
