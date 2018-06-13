//
//  MainVC.swift
//  ProjectHD
//
//  Created by Stephen Muscarella on 6/13/18.
//  Copyright © 2018 Elite Development. All rights reserved.
//

import UIKit

fileprivate let REPO_LIST_CVC: String = "RepoListCVC"

class MainVC: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var userTF: TF!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    let BaseUrl: String = "https://api.github.com/users/"
    let Layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    let SegmentTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Verdana", size: 14.0)!]
    
    var repos: [Repository] = [Repository]()
    var offset: Int = 1
    var targetSize: CGSize!
    var url: URL!
    var task: URLSessionDataTask?
    var userOrOrganization: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        Layout.minimumInteritemSpacing = 0
        Layout.minimumLineSpacing = 0
        Layout.scrollDirection = .vertical
        
        collectionView.collectionViewLayout = Layout
        collectionView.register(RepoListCVC.nib(), forCellWithReuseIdentifier: REPO_LIST_CVC)

        targetSize = CGSize(width: view.bounds.width, height: 100)
        
        userTF.addViewBackedBorder(side: .south, thickness: 1.0, color: UIColor.lightGray)
        userTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        segmentControl.tintColor = UIColor.white
        segmentControl.setTitle("List", forSegmentAt: 0)
        segmentControl.setTitle("Grid", forSegmentAt: 1)
        segmentControl.setTitleTextAttributes(SegmentTextAttributes, for: .normal)
        segmentControl.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 30)
    }
    
    @objc func textFieldDidChange() {

        guard let userOrOrganization = userTF.text, userOrOrganization.count > 0 else {
            return
        }
        
        offset = 1
        url = URL(string: BaseUrl + userOrOrganization + "/repos?page=\(offset)&per_page=10")!
        task?.cancel()

        task = URLSession.shared.dataTask(with: url) { (data, response, error) in

            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                // Convert the data to JSON
                if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [Any] {
                    
                    print(json)
                    
                    DispatchQueue.main.async {
                        
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        task?.resume()
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
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return targetSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: REPO_LIST_CVC, for: indexPath) as! RepoListCVC
        return cell
    }
    
}
