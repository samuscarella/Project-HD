//
//  MainVC.swift
//  ProjectHD
//
//  Created by Stephen Muscarella on 6/13/18.
//  Copyright © 2018 Elite Development. All rights reserved.
//

import UIKit

fileprivate let LOADING_CVC: String = "LoadingCVC"
fileprivate let REPO_LIST_CVC: String = "RepoListCVC"
fileprivate let REPO_GRID_CVC: String = "RepoGridCVC"

class MainVC: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var userTF: TF!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    
    let BaseUrl: String = "https://api.github.com/users/"
    let Layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    let SegmentTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Verdana", size: 14.0)!]
    let PerPage: Int = 10
    
    var repos: [Repository] = [Repository]()
    var offset: Int = 1
    var shouldShowLoadingCell: Bool = false
    var firstLoad: Bool = false
    var numberOfRepos: Int = 0
    var targetSize: CGSize!
    var url: URL!
    var task: URLSessionDataTask?
    var userOrOrganization: String?
    var refreshControl: UIRefreshControl?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        Layout.minimumInteritemSpacing = 0
        Layout.minimumLineSpacing = 5
        Layout.scrollDirection = .vertical
        
        targetSize = CGSize(width: view.bounds.width - 10, height: 100)
        
        userTF.addViewBackedBorder(side: .south, thickness: 1.0, color: UIColor.lightGray)
        userTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        collectionView.collectionViewLayout = Layout
        collectionView.register(LoadingCVC.nib(), forCellWithReuseIdentifier: LOADING_CVC)
        collectionView.register(RepoListCVC.nib(), forCellWithReuseIdentifier: REPO_LIST_CVC)
        collectionView.register(RepoGridCVC.nib(), forCellWithReuseIdentifier: REPO_GRID_CVC)
        
        segmentControl.tintColor = UIColor.white
        segmentControl.setTitle("List", forSegmentAt: 0)
        segmentControl.setTitle("Grid", forSegmentAt: 1)
        segmentControl.setTitleTextAttributes(SegmentTextAttributes, for: .normal)
        segmentControl.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 30)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func getNumberOfRepos() {
        
        guard self.userOrOrganization != nil else { return }
        
        url = URL(string: BaseUrl + self.userOrOrganization! + "/repos?type=all")!
        task = URLSession.shared.dataTask(with: url) { (data, response, error) in

            if let error = error {
                print(error.localizedDescription)
            }

            guard let data = data else { return }

            do {
                // Convert the data to JSON
                print(try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments))
                guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String:Any]] else {
                    self.shouldShowLoadingCell = false
                    return
                }
                
                self.numberOfRepos = jsonArray.count
                print(self.numberOfRepos)
                self.shouldShowLoadingCell = self.PerPage < self.numberOfRepos
                self.fetchRepos(refresh: true)

            } catch {
                print(error.localizedDescription)
            }
        }
        task?.resume()
    }
    
    func fetchNextRepos() {
        
        offset += 1
        refreshControl?.beginRefreshing()
        fetchRepos()
    }
    
    func fetchRepos(refresh: Bool = false) {
        
        task?.cancel()
        url = URL(string: BaseUrl + self.userOrOrganization! + "/repos?page=\(offset)&per_page=\(PerPage)")!
        task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                // Convert the data to JSON
                guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String:Any]] else {
                    self.shouldShowLoadingCell = false
                    return
                }
                
                if refresh {
                    self.repos = []
                }
                
                for json in jsonArray {
                        
                    let repository = Repository(json: json)
                    self.repos.append(repository)
                }
                
                self.firstLoad = true
                self.shouldShowLoadingCell = self.repos.count < self.numberOfRepos
                
                DispatchQueue.main.async {
                    
                    if self.repos.count > 0 {
                        
                        self.refreshControl = UIRefreshControl()
                        self.refreshControl?.addTarget(self, action: #selector(self.refreshRepos), for: .valueChanged)
                        self.collectionView.refreshControl = self.refreshControl
                        
                    } else {
                        self.refreshControl = nil
                    }
                    
                    self.refreshControl?.endRefreshing()
                    self.collectionView.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        task?.resume()
    }
    
    private func isLoadingIndexPath(_ indexPath: IndexPath) -> Bool {
        
        guard shouldShowLoadingCell else { return false }
        return indexPath.row == self.repos.count
    }
    
    @objc func textFieldDidChange() {
        
        guard let userOrOrganization = userTF.text, userOrOrganization.count > 0 else {
            return
        }
        
        self.offset = 1
        self.userOrOrganization = userOrOrganization
        self.timer?.invalidate()

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getNumberOfRepos), userInfo: nil, repeats: false)
    }
    
    @objc func refreshRepos() {
        
        offset = 1
        getNumberOfRepos()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableViewBottom.constant = keyboardSize.height
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {

        tableViewBottom.constant = 0
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        
        if segmentControl.selectedSegmentIndex == 0 {
            
            Layout.minimumLineSpacing = 5
            targetSize = CGSize(width: view.bounds.width - 10, height: 100)
            
        } else {
            
            Layout.minimumLineSpacing = 0
            targetSize = CGSize(width: view.bounds.width / 2 - 5, height: view.bounds.width / 2 - 5)
        }
        collectionView.reloadData()
    }
    
}

// MARK: - UITextFieldDelegates
extension MainVC {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "\n" {
            
            view.endEditing(true)
            return false
        }
        return true
    }
    
}

// MARK: - UICollectionViewDelegates
extension MainVC {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if !firstLoad {
            return 0
        }
        return shouldShowLoadingCell ? repos.count + 1 : repos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isLoadingIndexPath(indexPath) {
            return CGSize(width: view.bounds.width, height: 50)
        }
        return targetSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isLoadingIndexPath(indexPath) {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LOADING_CVC, for: indexPath) as! LoadingCVC
            return cell
        }
        
        let repo = repos[indexPath.row]
       
        if segmentControl.selectedSegmentIndex == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: REPO_LIST_CVC, for: indexPath) as! RepoListCVC
            cell.configureCell(repo: repo)
            return cell

        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: REPO_GRID_CVC, for: indexPath) as! RepoGridCVC
            cell.configureCell(repo: repo)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard isLoadingIndexPath(indexPath) else { return }
        fetchNextRepos()
    }
    
}
