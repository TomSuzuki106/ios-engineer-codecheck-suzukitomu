//
//  RepositoryDetailViewModelTests.swift
//  iOSEngineerCodeCheckTests
//
//  Created by 鈴木斗夢 on 2024/06/17.
//  Copyright © 2024 YUMEMI Inc. All rights reserved.
//

import XCTest
@testable import iOSEngineerCodeCheck

class RepositoryDetailViewModelTests: XCTestCase {
    
    var viewModel: RepositoryDetailViewModel!
    var mockDelegate: MockRepositoryDetailViewModelDelegate!
    var mockImageFetcher: MockGitHubRepositoryImageFetcher!
    
    override func setUp() {
        super.setUp()
        let repository = RepositoryModel(fullName: "test/repo", language: "Swift", stargazersCount: 10, watchersCount: 5, forksCount: 3, openIssuesCount: 2, owner: Owner(avatarURL: "https://example.com/avatar.png"))
        mockDelegate = MockRepositoryDetailViewModelDelegate()
        mockImageFetcher = MockGitHubRepositoryImageFetcher()
        viewModel = RepositoryDetailViewModel(repository: repository, delegate: mockDelegate, imageFetcher: mockImageFetcher)
    }
    
    func testFetchRepositoryImage_Success() {
        mockImageFetcher.fetchRepositoryImageResult = .success(UIImage())
        
        viewModel.fetchRepositoryImage()
        
        XCTAssertTrue(self.mockDelegate.updateRepositoryImageCalled)
        XCTAssertFalse(self.mockDelegate.showPlaceholderImageCalled)
    }
    
    func testFetchRepositoryImage_Failure() {
        mockImageFetcher.fetchRepositoryImageResult = .failure(NSError(domain: "Test", code: 0, userInfo: nil))
        
        viewModel.fetchRepositoryImage()
        
        XCTAssertFalse(self.mockDelegate.updateRepositoryImageCalled)
        XCTAssertTrue(self.mockDelegate.showPlaceholderImageCalled)
    }
}

class MockRepositoryDetailViewModelDelegate: RepositoryDetailViewModelDelegate {
    var updateRepositoryImageCalled = false
    var showPlaceholderImageCalled = false
    
    func updateRepositoryImage(_ image: UIImage?) {
        updateRepositoryImageCalled = true
    }
    
    func showPlaceholderImage() {
        showPlaceholderImageCalled = true
    }
}

class MockGitHubRepositoryImageFetcher: GitHubRepositoryImageFetching {
    var fetchRepositoryImageResult: Result<UIImage?, Error>?
    
    func fetchRepositoryImage(from urlString: String, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        if let result = fetchRepositoryImageResult {
            completion(result)
        }
    }
}
