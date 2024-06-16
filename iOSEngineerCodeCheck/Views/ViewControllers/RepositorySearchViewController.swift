//
//  RepositorySearchViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

class RepositorySearchViewController: UIViewController {
    
    let searchBar = UISearchBar()
    let tableView = UITableView()
    var viewModel: RepositorySearchViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        title = "Root View Controller"
        // ビューの背景色を、ダークモードとライトモードに対応した色に設定
        view.backgroundColor = UIColor.dynamicBackgroundColor
        searchBar.placeholder = "GitHubのリポジトリを検索"
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        viewModel = RepositorySearchViewModel(delegate: self)
    }
    
    // RepositorySearchViewControllerの破棄時に、URLSessionTaskを解放
    override func viewWillDisappear(_ animated: Bool) {
        GitHubRepositorySearcher.shared.cancelSearch()
    }
    
    func setupUI() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        searchBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, height: 56)
        tableView.anchor(top: searchBar.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
}

extension RepositorySearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        GitHubRepositorySearcher.shared.cancelSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text, !searchTerm.isEmpty else { return }
        searchBar.resignFirstResponder() // キーボードを閉じる
        viewModel.searchRepositories(with: searchTerm)
    }
}

extension RepositorySearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchRepositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let repository = viewModel.searchRepositories[indexPath.row]
        cell.textLabel?.text = repository.fullName
        cell.detailTextLabel?.text = repository.language
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = viewModel.searchRepositories[indexPath.row]
        let detailViewController = RepositoryDetailViewController(repository: repository)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension RepositorySearchViewController: RepositorySearchViewModelDelegate {
    func updateRepositories() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func showError(message: Error) {
        DispatchQueue.main.async {
            self.showErrorAlert(for: message)
        }
    }
    
    private func showErrorAlert(for error: Error) {
        let message: String
        switch error {
        case is URLError:
            message = "ネットワークエラーが発生しました。インターネット接続を確認してください。"
        default:
            message = "エラーが発生しました。"
        }
        let alertController = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
// UIScrollViewDelegateのメソッドをUITableViewDelegateの拡張として実装
extension RepositorySearchViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder() // キーボードを閉じる
    }
}
