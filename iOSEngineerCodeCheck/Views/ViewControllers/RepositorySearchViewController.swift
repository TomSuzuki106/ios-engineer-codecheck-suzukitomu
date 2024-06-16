//
//  RepositorySearchViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

class RepositorySearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UINavigationControllerDelegate {
    
    let searchBar = UISearchBar()
    let tableView = UITableView()
    var searchRepositories: [RepositoryModel] = []
    var selectedRowIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        title = "Root View Controller"
        // ビューの背景色を、ダークモードとライトモードに対応した色に設定
        view.backgroundColor = UIColor.dynamicBackgroundColor
        searchBar.text = "GitHubのリポジトリを検索できるよー"
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // RepositorySearchViewControllerの破棄時に、URLSessionTaskを解放
    override func viewWillDisappear(_ animated: Bool) {
        NetworkManager.shared.cancelSearch()
    }
    
    func setupUI() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        searchBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, height: 56)
        tableView.anchor(top: searchBar.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // 検索バーの初期値を削除
        searchBar.text = ""
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NetworkManager.shared.cancelSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text, !searchTerm.isEmpty else { return }

        NetworkManager.shared.searchRepositories(with: searchTerm) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let repositories):
                self.searchRepositories = repositories
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showErrorAlert(for: error)
                }
            }
        }
    }

    func showErrorAlert(for error: Error) {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "Detail" else { return }
        guard let repositoryDetailViewController = segue.destination as? RepositoryDetailViewController else { return }
        repositoryDetailViewController.repositorySearchViewController = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchRepositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        guard indexPath.row < searchRepositories.count else { return cell }
        let repository = searchRepositories[indexPath.row]
        cell.textLabel?.text = repository.fullName
        cell.detailTextLabel?.text = repository.language
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRowIndex = indexPath.row
        let detailViewController = RepositoryDetailViewController()
        detailViewController.repositorySearchViewController = self
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
