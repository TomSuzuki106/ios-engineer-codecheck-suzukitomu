//
//  RepositoryDetailViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

class RepositoryDetailViewController: UIViewController {
    
    @IBOutlet weak var repositoryImageView: UIImageView!
    @IBOutlet weak var repositoryNameLabel: UILabel!
    @IBOutlet weak var programmingLanguageLabel: UILabel!
    @IBOutlet weak var stargazersCountLabel: UILabel!
    @IBOutlet weak var watchersCountLabel: UILabel!
    @IBOutlet weak var forksCountLabel: UILabel!
    @IBOutlet weak var openIssuesCountLabel: UILabel!
    var repositorySearchViewController: RepositorySearchViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let repository = repositorySearchViewController.searchRepositories[repositorySearchViewController.selectedRowIndex]
        programmingLanguageLabel.text = "Written in \(repository["language"] as? String ?? "")"
        stargazersCountLabel.text = "\(repository["stargazers_count"] as? Int ?? 0) stars"
        watchersCountLabel.text = "\(repository["wachers_count"] as? Int ?? 0) watchers"
        forksCountLabel.text = "\(repository["forks_count"] as? Int ?? 0) forks"
        openIssuesCountLabel.text = "\(repository["open_issues_count"] as? Int ?? 0) open issues"
        fetchRepositoryImage()
    }
    
    func fetchRepositoryImage() {
        let repository = repositorySearchViewController.searchRepositories[repositorySearchViewController.selectedRowIndex]
        repositoryNameLabel.text = repository["full_name"] as? String
        guard let owner = repository["owner"] as? [String: Any] else { return }
        guard let imgURL = owner["avatar_url"] as? String else { return }
        URLSession.shared.dataTask(with: URL(string: imgURL)!) { (data, res, err) in
            let img = UIImage(data: data!)!
            DispatchQueue.main.async {
                self.repositoryImageView.image = img
            }
        }.resume()
    }
}
