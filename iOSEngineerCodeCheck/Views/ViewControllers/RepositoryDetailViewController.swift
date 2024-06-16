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
    var repository: RepositoryModel
    var viewModel: RepositoryDetailViewModel!
    
    init(repository: RepositoryModel) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupData()
        self.setupUI()
        viewModel = RepositoryDetailViewModel(repository: repository, delegate: self)
        viewModel.fetchRepositoryImage()
    }
    
    private func setupData() {
        repositoryNameLabel.text = repository.fullName
        programmingLanguageLabel.text = "Written in \(repository.language ?? "Unknown")"
        stargazersCountLabel.text = "\(repository.stargazersCount) stars"
        watchersCountLabel.text = "\(repository.watchersCount) watchers"
        forksCountLabel.text = "\(repository.forksCount) forks"
        openIssuesCountLabel.text = "\(repository.openIssuesCount) open issues"
        fetchRepositoryImage(from: repository.owner.avatarURL)
    }
    
    // デバイスの画面の向きが変更されるときに呼び出されるメソッド
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.setupUI()
        })
    }
    
    private func setupUI() {
        // ビューの背景色を、ダークモードとライトモードに対応した色に設定
        view.backgroundColor = UIColor.dynamicBackgroundColor
        
        setupRepositoryImageView()
        configureLabels()
        
        let isLandscape = view.bounds.width > view.bounds.height
        if isLandscape {
            // デバイス横向きの場合のレイアウトを設定
            setupLandscapeUI()
        } else {
            // デバイス縦向きの場合のレイアウトを設定
            setupPortraitUI()
        }
    }
    
    private func setupRepositoryImageView() {
        view.addSubview(repositoryImageView)
        repositoryImageView.setDimensions(height: view.frame.width * 0.9, width: view.frame.width * 0.9)
        repositoryImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
    }
    // デバイス縦向きの場合のレイアウトを設定
    private func setupPortraitUI() {
        let labelsStackView = UIStackView(arrangedSubviews: [createLanguageStarStackView(), watchersCountLabel, forksCountLabel, openIssuesCountLabel])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 16
        
        let mainStackView = UIStackView(arrangedSubviews: [repositoryNameLabel, labelsStackView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        
        view.addSubview(mainStackView)
        mainStackView.anchor(top: repositoryImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 16, paddingRight: 16)
    }

    // デバイス横向きの場合のレイアウトを設定
    private func setupLandscapeUI() {
        let rightStackView = UIStackView(arrangedSubviews: [repositoryNameLabel, createLanguageStarStackView(), watchersCountLabel, forksCountLabel, openIssuesCountLabel])
        rightStackView.axis = .vertical
        rightStackView.spacing = 16
        
        let sideBySideStackView = UIStackView(arrangedSubviews: [repositoryImageView, rightStackView])
        sideBySideStackView.axis = .horizontal
        sideBySideStackView.spacing = 16
        sideBySideStackView.distribution = .fillEqually
        
        view.addSubview(sideBySideStackView)
        sideBySideStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 16, paddingRight: 16)
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
    // ラベルの設定を行うヘルパーメソッド
    private func configureLabel(label: UILabel, textAlignment: NSTextAlignment, fontSize: CGFloat, isBold: Bool = false) {
        label.textAlignment = textAlignment
        label.font = isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
    }
    // プログラミング言語とスター数のスタックビューを作成するメソッド
    private func createLanguageStarStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [programmingLanguageLabel, stargazersCountLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        return stackView
    }
    
    func fetchRepositoryImage(from urlString: String) {
        GitHubRepositoryImageFetcher.shared.fetchRepositoryImage(from: urlString) { [weak self] result in
            switch result {
            case .success(let img):
                DispatchQueue.main.async {
                    self?.repositoryImageView.image = img
                }
            case .failure:
                self?.showPlaceholderImage()
            }
        }
    }
}

extension RepositoryDetailViewController: RepositoryDetailViewModelDelegate {
    func updateRepositoryImage(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.repositoryImageView.image = image
        }
    }
    
    func showPlaceholderImage() {
        DispatchQueue.main.async {
            let placeholderImage = UIImage(named: "placeholder")
            self.repositoryImageView.image = placeholderImage
        }
    }
}
