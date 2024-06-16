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
    var searchRepositories: [[String: Any]] = []
    var searchTaskForRepositories: URLSessionTask?
    var searchTerm: String?
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
        searchTaskForRepositories?.cancel()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 入力された検索ワードが空でないことを確認
        guard let searchTerm = searchBar.text, !searchTerm.isEmpty else { return }
        
        // 検索処理の呼び出し
        searchRepositories(with: searchTerm) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let repositories):
                    // 成功した場合、取得したリポジトリのデータを保存し、テーブルビューをリロード
                    self.searchRepositories = repositories
                    self.tableView.reloadData()
                case .failure(let error):
                    // エラーが発生した場合、エラーメッセージを表示
                    self.showErrorAlert(for: error)
                }
            }
        }
    }

    // APIリクエストを実行するメソッド
    func searchRepositories(with searchTerm: String, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        let searchAPIURLString = "https://api.github.com/search/repositories?q=\(searchTerm)"
        guard let searchAPIURL = URL(string: searchAPIURLString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: searchAPIURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "Data is nil", code: -1, userInfo: nil)))
                return
            }
            do {
                // JSONデータをパース
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let items = json["items"] as? [[String: Any]] {
                    completion(.success(items))
                } else {
                    completion(.failure(NSError(domain: "Failed to parse JSON", code: -1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume() // データタスクを実行
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
        let repository = searchRepositories[indexPath.row]
        cell.textLabel?.text = repository["full_name"] as? String ?? ""
        cell.detailTextLabel?.text = repository["language"] as? String ?? ""
        cell.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRowIndex = indexPath.row
        let detailViewController = RepositoryDetailViewController()
        detailViewController.repositorySearchViewController = self
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
