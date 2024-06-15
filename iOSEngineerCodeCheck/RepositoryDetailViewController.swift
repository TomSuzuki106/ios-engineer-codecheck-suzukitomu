//
//  RepositoryDetailViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

class RepositoryDetailViewController: UIViewController {
    
    let repositoryImageView = UIImageView()
    let repositoryNameLabel = UILabel()
    let programmingLanguageLabel = UILabel()
    let stargazersCountLabel = UILabel()
    let watchersCountLabel = UILabel()
    let forksCountLabel = UILabel()
    let openIssuesCountLabel = UILabel()
    var repositorySearchViewController: RepositorySearchViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        guard let searchViewController = repositorySearchViewController else { return }
        guard let selectedIndex = searchViewController.selectedRowIndex else { return }
        let repository = searchViewController.searchRepositories[selectedIndex]
        
        programmingLanguageLabel.text = "Written in \(repository["language"] as? String ?? "")"
        stargazersCountLabel.text = "\(repository["stargazers_count"] as? Int ?? 0) stars"
        watchersCountLabel.text = "\(repository["wachers_count"] as? Int ?? 0) watchers"
        forksCountLabel.text = "\(repository["forks_count"] as? Int ?? 0) forks"
        openIssuesCountLabel.text = "\(repository["open_issues_count"] as? Int ?? 0) open issues"
        fetchRepositoryImage()
    }
    
    func setupUI() {
        // ビューの背景色を設定
        view.backgroundColor = UIColor.dynamicBackgroundColor
        
        // リポジトリの画像ビューをビューに追加
        view.addSubview(repositoryImageView)
        
        // プログラミング言語とスター数、ウォッチャー数、フォーク数、オープンイシュー数のラベルを含むスタックビューを作成
        let labelsStackView = UIStackView(arrangedSubviews: [createLanguageStarStackView(), watchersCountLabel, forksCountLabel, openIssuesCountLabel])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 16
        
        // リポジトリ名とその他のラベルのスタックビューを作成
        let mainStackView = UIStackView(arrangedSubviews: [repositoryNameLabel, labelsStackView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        
        // メインスタックビューをビューに追加
        view.addSubview(mainStackView)
        
        // リポジトリ画像ビューのサイズと位置を設定
        repositoryImageView.setDimensions(height: view.frame.width * 0.9, width: view.frame.width * 0.9)
        repositoryImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        // ラベルの設定を行う
        configureLabel(label: repositoryNameLabel, textAlignment: .center, fontSize: 24, isBold: true)
        configureLabel(label: programmingLanguageLabel, textAlignment: .left, fontSize: 18, isBold: true)
        configureLabel(label: stargazersCountLabel, textAlignment: .right, fontSize: 18)
        configureLabel(label: watchersCountLabel, textAlignment: .right, fontSize: 18)
        configureLabel(label: forksCountLabel, textAlignment: .right, fontSize: 18)
        configureLabel(label: openIssuesCountLabel, textAlignment: .right, fontSize: 18)
        
        // メインスタックビューのアンカーを設定
        mainStackView.anchor(top: repositoryImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 16, paddingRight: 16)
    }

    // プログラミング言語とスター数のスタックビューを作成するメソッド
    func createLanguageStarStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [programmingLanguageLabel, stargazersCountLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        return stackView
    }

    // ラベルの設定を行うヘルパーメソッド
    func configureLabel(label: UILabel, textAlignment: NSTextAlignment, fontSize: CGFloat, isBold: Bool = false) {
        label.textAlignment = textAlignment
        label.font = isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
    }
    
    func fetchRepositoryImage() {
        guard let searchViewController = repositorySearchViewController else { return }
        guard let selectedIndex = searchViewController.selectedRowIndex else { return }
        let repository = searchViewController.searchRepositories[selectedIndex]
        repositoryNameLabel.text = repository["full_name"] as? String
        guard let owner = repository["owner"] as? [String: Any] else { return }
        guard let avatarURLString = owner["avatar_url"] as? String else { return }
        guard let avatarURL = URL(string: avatarURLString) else { return }
        URLSession.shared.dataTask(with: avatarURL) { (data, response, error) in
            guard let imageData = data, let image = UIImage(data: imageData) else { return }
            DispatchQueue.main.async {
                self.repositoryImageView.image = image
            }
        }.resume()
    }
}
