//
//  iRepositorySearchViewModelTests.swift
//  iOSEngineerCodeCheckTests
//
//  Created by 鈴木斗夢 on 2024/06/17.
//  Copyright © 2024 YUMEMI Inc. All rights reserved.
//


import XCTest
@testable import iOSEngineerCodeCheck

class RepositorySearchViewModelTests: XCTestCase {
    var viewModel: RepositorySearchViewModel!
    var mockDelegate: MockRepositorySearchViewModelDelegate!
    var mockRepositorySearcher: MockGitHubRepositorySearcher!
    
    override func setUp() {
        super.setUp()
        mockDelegate = MockRepositorySearchViewModelDelegate()
        mockRepositorySearcher = MockGitHubRepositorySearcher()
        viewModel = RepositorySearchViewModel(delegate: mockDelegate, repositorySearcher: mockRepositorySearcher)
    }
    
    override func tearDown() {
        viewModel = nil
        mockDelegate = nil
        mockRepositorySearcher = nil
        super.tearDown()
    }
    
    func testSearchRepositories_Success() {
        // Given
        let searchTerm = "swift"
        let expectedRepositories = [RepositoryModel(fullName: "repo1", language: "Swift", stargazersCount: 100, watchersCount: 50, forksCount: 20, openIssuesCount: 10, owner: Owner(avatarURL: "https://example.com/avatar.png"))]
        
        mockRepositorySearcher.result = .success(expectedRepositories)
        
        // When
        viewModel.searchRepositories(with: searchTerm)
        
        // Then
        XCTAssertEqual(viewModel.searchRepositories, expectedRepositories)
        XCTAssertTrue(mockDelegate.updateRepositoriesCalled)
    }
    
    func testSearchRepositories_Failure() {
        // Given
        let searchTerm = "swift"
        let expectedError = NSError(domain: "SearchError", code: -1, userInfo: [NSLocalizedDescriptionKey: "The operation couldn’t be completed. (SearchError error -1.)"])
        
        mockRepositorySearcher.result = .failure(expectedError)
        
        // When
        viewModel.searchRepositories(with: searchTerm)
        
        // Then
        XCTAssertTrue(viewModel.searchRepositories.isEmpty)
        XCTAssertTrue(mockDelegate.showErrorCalled)
        XCTAssertEqual(mockDelegate.errorMessage, expectedError.localizedDescription)
    }
    
    func testCancelSearch() {
        // When
        viewModel.cancelSearch()
        
        // Then
        XCTAssertTrue(mockRepositorySearcher.cancelSearchCalled)
    }
}

class MockRepositorySearchViewModelDelegate: RepositorySearchViewModelDelegate {
    var updateRepositoriesCalled = false
    var showErrorCalled = false
    var errorMessage: String?
    
    func updateRepositories() {
        updateRepositoriesCalled = true
    }
    
    func showError(message: Error) {
        showErrorCalled = true
        errorMessage = message.localizedDescription
    }
    
    func didReceiveRepositories(_ repositories: [RepositoryModel]) {
        updateRepositoriesCalled = true
    }
    
    func didFailToFetchRepositories(with error: Error) {
        showErrorCalled = true
        errorMessage = error.localizedDescription
    }
}

class MockGitHubRepositorySearcher: GitHubRepositorySearching {
    var result: Result<[RepositoryModel], Error> = .success([])
    var cancelSearchCalled = false
    
    func searchRepositories(with searchTerm: String, completion: @escaping (Result<[RepositoryModel], Error>) -> Void) {
        completion(result)
    }
    
    func cancelSearch() {
        cancelSearchCalled = true
    }
}
