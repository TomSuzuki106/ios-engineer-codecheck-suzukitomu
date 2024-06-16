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
        // ビューの背景色を、ダークモードとライトモードに対応した色に設定
        view.backgroundColor = UIColor.dynamicBackgroundColor
        // 現在のデバイスの向きを取得して updateLayout を呼び出す
        let currentSize = view.bounds.size
        updateLayout(for: currentSize)
        
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
    
    // デバイスの画面の向きが変更されるときに呼び出されるメソッド
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.updateLayout(for: size)
        })
    }
    
    private func updateLayout(for size: CGSize) {
        view.subviews.forEach { $0.removeConstraints($0.constraints) }
        
        // 現在のデバイスの向きが横向きかどうかを判定
        let isLandscape = size.width > size.height
        if isLandscape {
            // デバイス横向きの場合のレイアウトを設定
            setupLandscapeUI()
        } else {
            // デバイス縦向きの場合のレイアウトを設定
            setupPortraitUI()
        }
        // ラベルの設定を行う
        configureLabels()
    }
    
    // デバイス横向きの場合のレイアウトを設定
    private func setupLandscapeUI() {
        let rightStackView = UIStackView(arrangedSubviews: [repositoryNameLabel, createLanguageStarStackView(), watchersCountLabel, forksCountLabel, openIssuesCountLabel])
        rightStackView.axis = .vertical
        rightStackView.spacing = 16
        
        // 左半分に repositoryImageView、右半分に rightStackView を配置するスタックビューを作成
        let sideBySideStackView = UIStackView(arrangedSubviews: [repositoryImageView, rightStackView])
        sideBySideStackView.axis = .horizontal
        sideBySideStackView.spacing = 16
        sideBySideStackView.distribution = .fillEqually
        
        view.addSubview(sideBySideStackView)
        sideBySideStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 16, paddingRight: 16)
        
        repositoryImageView.setDimensions(height: view.frame.height - 32, width: view.frame.width / 2 - 32)
    }
    
    
    // デバイス縦向きの場合のレイアウトを設定
    private func setupPortraitUI() {
        view.addSubview(repositoryImageView)
        
        // プログラミング言語とスター数、ウォッチャー数、フォーク数、オープンイシュー数のラベルを含むスタックビューを作成
        let labelsStackView = UIStackView(arrangedSubviews: [createLanguageStarStackView(), watchersCountLabel, forksCountLabel, openIssuesCountLabel])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 16
        
        // リポジトリ名とその他のラベルのスタックビューを作成
        let mainStackView = UIStackView(arrangedSubviews: [repositoryNameLabel, labelsStackView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        
        view.addSubview(mainStackView)
        
        repositoryImageView.setDimensions(height: view.frame.width * 0.9, width: view.frame.width * 0.9)
        repositoryImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        mainStackView.anchor(top: repositoryImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 16, paddingRight: 16)
    }
    
    // ラベルの設定を行う
    private func configureLabels() {
        configureLabel(label: repositoryNameLabel, textAlignment: .center, fontSize: 24, isBold: true)
        configureLabel(label: programmingLanguageLabel, textAlignment: .left, fontSize: 18, isBold: true)
        configureLabel(label: stargazersCountLabel, textAlignment: .right, fontSize: 18)
        configureLabel(label: watchersCountLabel, textAlignment: .right, fontSize: 18)
        configureLabel(label: forksCountLabel, textAlignment: .right, fontSize: 18)
        configureLabel(label: openIssuesCountLabel, textAlignment: .right, fontSize: 18)
    }
    
    // プログラミング言語とスター数のスタックビューを作成するメソッド
    private func createLanguageStarStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [programmingLanguageLabel, stargazersCountLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        return stackView
    }
    
    // ラベルの設定を行うヘルパーメソッド
    private func configureLabel(label: UILabel, textAlignment: NSTextAlignment, fontSize: CGFloat, isBold: Bool = false) {
        label.textAlignment = textAlignment
        label.font = isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
    }
    
    private func fetchRepositoryImage() {
        guard let searchViewController = repositorySearchViewController else { return }
        guard let selectedIndex = searchViewController.selectedRowIndex else { return }
        let repository = searchViewController.searchRepositories[selectedIndex]
        repositoryNameLabel.text = repository["full_name"] as? String
        guard let owner = repository["owner"] as? [String: Any] else { return }
        guard let avatarURLString = owner["avatar_url"] as? String else { return }
        guard let avatarURL = URL(string: avatarURLString) else { return }
        URLSession.shared.dataTask(with: avatarURL) { [weak self] (data, response, error) in
            guard let self = self else { return }
            guard let imageData = data, let image = UIImage(data: imageData) else { return }
            DispatchQueue.main.async {
                self.repositoryImageView.image = image
            }
        }.resume()

    }
}
